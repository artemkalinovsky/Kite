import Foundation

// MARK: - XMLObjectDeserialization

/// Conforming types can be constructed from an ``XMLIndexer`` node.
public protocol XMLObjectDeserialization {
    static func deserialize(_ node: XMLIndexer) throws -> Self
}

// MARK: - XMLValueDeserialization

/// Conforming types can be constructed from the text content of an ``XMLIndexer`` leaf node.
public protocol XMLValueDeserialization {
    static func deserialize(_ node: XMLIndexer) throws -> Self
}

// MARK: - Primitive conformances

extension String: XMLValueDeserialization {
    public static func deserialize(_ node: XMLIndexer) throws -> String {
        guard case .element(let n) = node.backing, let text = n.text else {
            throw XMLDeserializerError.xmlDeserializationFailed("Expected text content for String.")
        }
        return text
    }
}

extension Int: XMLValueDeserialization {
    public static func deserialize(_ node: XMLIndexer) throws -> Int {
        guard case .element(let n) = node.backing,
              let text = n.text,
              let value = Int(text.trimmingCharacters(in: .whitespaces)) else {
            throw XMLDeserializerError.xmlDeserializationFailed("Cannot convert to Int.")
        }
        return value
    }
}

extension Double: XMLValueDeserialization {
    public static func deserialize(_ node: XMLIndexer) throws -> Double {
        guard case .element(let n) = node.backing,
              let text = n.text,
              let value = Double(text.trimmingCharacters(in: .whitespaces)) else {
            throw XMLDeserializerError.xmlDeserializationFailed("Cannot convert to Double.")
        }
        return value
    }
}

extension Float: XMLValueDeserialization {
    public static func deserialize(_ node: XMLIndexer) throws -> Float {
        guard case .element(let n) = node.backing,
              let text = n.text,
              let value = Float(text.trimmingCharacters(in: .whitespaces)) else {
            throw XMLDeserializerError.xmlDeserializationFailed("Cannot convert to Float.")
        }
        return value
    }
}

extension Bool: XMLValueDeserialization {
    public static func deserialize(_ node: XMLIndexer) throws -> Bool {
        guard case .element(let n) = node.backing, let text = n.text else {
            throw XMLDeserializerError.xmlDeserializationFailed("Expected text content for Bool.")
        }
        switch text.trimmingCharacters(in: .whitespaces).lowercased() {
        case "true", "yes", "1":  return true
        case "false", "no", "0": return false
        default:
            throw XMLDeserializerError.xmlDeserializationFailed("Cannot convert '\(text)' to Bool.")
        }
    }
}
