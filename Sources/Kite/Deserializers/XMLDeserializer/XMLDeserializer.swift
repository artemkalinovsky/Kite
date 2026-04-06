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

    init(transform: @Sendable @escaping (Data) throws -> T) {
        self.transform = transform
    }

    public func deserialize(data: Data) throws -> T {
        try transform(data)
    }
}

extension XMLDeserializer where T == Data {
    public init() {
        self.transform = { data in
            data
        }
    }
}

extension XMLDeserializer where T == XMLIndexer {
    public init() {
        self.transform = { xmlData in
            XMLHash.lazy(xmlData)
        }
    }
}

extension XMLDeserializer where T: XMLObjectDeserialization {
    public init() {
        self.transform = { xmlData in
            let xml = XMLHash.lazy(xmlData)
            guard let rootElement = xml.documentRootElement else {
                throw XMLDeserializerError.xmlDeserializationFailed("Missing root XML element.")
            }
            return try rootElement.value()
        }
    }

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
