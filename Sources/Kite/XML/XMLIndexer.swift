// MARK: - Internal XML node

struct XMLNode: Sendable {
    let name: String
    let text: String?
    let attributes: [String: String]
    let children: [XMLNode]
}

// MARK: - Internal backing

enum XMLIndexerBacking: Sendable {
    case document([XMLNode])
    case element(XMLNode)
    case list([XMLNode])
    case notFound(key: String)
}

// MARK: - Public XMLIndexer

/// Represents a position in a parsed XML document.
///
/// Navigate the tree with subscript notation and extract typed values with ``value()``.
public struct XMLIndexer: Sendable {
    let backing: XMLIndexerBacking

    init(_ backing: XMLIndexerBacking) {
        self.backing = backing
    }

    // MARK: Subscript

    /// Returns a child indexer matching `key`.
    public subscript(key: String) -> XMLIndexer {
        let matches: [XMLNode]
        switch backing {
        case .document(let roots):
            matches = roots.filter { $0.name == key }
        case .element(let node):
            matches = node.children.filter { $0.name == key }
        case .list(let nodes):
            matches = nodes.flatMap { $0.children.filter { $0.name == key } }
        case .notFound:
            return self
        }
        return XMLIndexer(nodes: matches, key: key)
    }

    // MARK: Children

    /// All direct children as individual indexers.
    public var children: [XMLIndexer] {
        switch backing {
        case .document(let roots): return roots.map { XMLIndexer(.element($0)) }
        case .element(let node):   return node.children.map { XMLIndexer(.element($0)) }
        case .list(let nodes):     return nodes.map { XMLIndexer(.element($0)) }
        case .notFound:            return []
        }
    }

    // MARK: Private helpers

    private init(nodes: [XMLNode], key: String) {
        switch nodes.count {
        case 0:  self.init(.notFound(key: key))
        case 1:  self.init(.element(nodes[0]))
        default: self.init(.list(nodes))
        }
    }
}

// MARK: - value() overloads

extension XMLIndexer {
    /// Deserializes this node as a single `XMLObjectDeserialization` value.
    public func value<T: XMLObjectDeserialization>() throws -> T {
        switch backing {
        case .element(let node):
            return try T.deserialize(XMLIndexer(.element(node)))
        case .notFound(let key):
            throw XMLDeserializerError.xmlDeserializationFailed("Element not found: \(key)")
        case .list:
            throw XMLDeserializerError.xmlDeserializationFailed("Expected a single element, found a list.")
        case .document:
            throw XMLDeserializerError.xmlDeserializationFailed("Cannot deserialize a document node as an object.")
        }
    }

    /// Deserializes this node as an array of `XMLObjectDeserialization` values.
    public func value<T: XMLObjectDeserialization>() throws -> [T] {
        switch backing {
        case .list(let nodes):
            return try nodes.map { try T.deserialize(XMLIndexer(.element($0))) }
        case .element(let node):
            return try [T.deserialize(XMLIndexer(.element(node)))]
        case .notFound, .document:
            return []
        }
    }

    /// Deserializes this node's text content as a `XMLValueDeserialization` primitive.
    public func value<T: XMLValueDeserialization>() throws -> T {
        try T.deserialize(self)
    }
}
