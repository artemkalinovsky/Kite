import Foundation

public enum JSONDeserializerError: LocalizedError {
    case jsonDeserializableInitFailed(String)
    case decodingFailed(underlying: Error, targetType: String)

    public var errorDescription: String? {
        switch self {
        case .jsonDeserializableInitFailed(let message):
            message
        case .decodingFailed(let underlying, let targetType):
            "Failed to decode \(targetType): \(underlying.localizedDescription)"
        }
    }
}

public struct JSONDeserializer<T>: ResponseDataDeserializer {
    private let transform: @Sendable (Data) throws -> T

    public init() {
        self.transform = { data in
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let object = jsonObject as? T else {
                throw JSONDeserializerError.jsonDeserializableInitFailed(
                    "Wrong result type: \(type(of: jsonObject)). Expected \(T.self)"
                )
            }
            return object
        }
    }

    init(transform: @Sendable @escaping (Data) throws -> T) {
        self.transform = transform
    }

    public func deserialize(data: Data) async throws -> T {
        try transform(data)
    }
}

extension JSONDeserializer where T: Decodable {
    public static func singleObjectDeserializer(keyPath path: String...) -> JSONDeserializer<T> {
        JSONDeserializer<T>(
            transform: { data in
                let jsonDecoder = JSONDecoder()
                do {
                    if path.isEmpty {
                        return try jsonDecoder.decode(T.self, from: data)
                    } else {
                        return try jsonDecoder.decode(T.self, from: data, keyPath: path.joined(separator: "."))
                    }
                } catch {
                    throw JSONDeserializerError.decodingFailed(
                        underlying: error,
                        targetType: String(describing: T.self)
                    )
                }
            }
        )
    }

    public static func collectionDeserializer(keyPath path: String...) -> JSONDeserializer<[T]> {
        JSONDeserializer<[T]>(
            transform: { data in
                let jsonDecoder = JSONDecoder()
                do {
                    if path.isEmpty {
                        return try jsonDecoder.decode([T].self, from: data)
                    } else {
                        return try jsonDecoder.decode([T].self, from: data, keyPath: path.joined(separator: "."))
                    }
                } catch {
                    throw JSONDeserializerError.decodingFailed(
                        underlying: error,
                        targetType: String(describing: [T].self)
                    )
                }
            }
        )
    }
}
