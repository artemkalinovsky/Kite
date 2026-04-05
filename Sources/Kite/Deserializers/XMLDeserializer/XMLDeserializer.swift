import Foundation
import SWXMLHash

public enum XMLDeserializerError: LocalizedError {
    case xmlDeserializationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .xmlDeserializationFailed(let message):
            message
        }
    }
}

public struct XMLDeserializer<T>: ResponseDataDeserializer {
    private let transform: @Sendable (Data) throws -> T

    public init() {
        self.transform = { xmlObject in
            if let xmlObject = xmlObject as? T {
                return xmlObject
            }
            throw XMLDeserializerError.xmlDeserializationFailed(
                "Wrong result type: \(type(of: xmlObject)). Expected \(T.self)"
            )
        }
    }

    init(transform: @Sendable @escaping (Data) throws -> T) {
        self.transform = transform
    }

    public func deserialize(data: Data) async throws -> T {
        try transform(data)
    }
}

extension XMLDeserializer where T: XMLObjectDeserialization {
    public static func singleObjectDeserializer(keyPath path: String...) -> XMLDeserializer<T> {
        XMLDeserializer<T>(
            transform: { xmlData in
                let xml = XMLHash.lazy(xmlData)
                return try xml[path].value()
            }
        )
    }

    public static func collectionDeserializer(keyPath path: String...) -> XMLDeserializer<[T]> {
        XMLDeserializer<[T]>(
            transform: { xmlData in
                let xml = XMLHash.lazy(xmlData)
                return try xml[path].value()
            }
        )
    }
}
