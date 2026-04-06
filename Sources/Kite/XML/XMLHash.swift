import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Entry point for parsing XML data into an ``XMLIndexer``.
public enum XMLHash {
    /// Parses `data` and returns a document-level ``XMLIndexer``.
    ///
    /// - Throws: The underlying `XMLParser` error for structurally malformed documents
    ///   (e.g. mismatched tags). Documents that are syntactically valid but contain no
    ///   element nodes (e.g. comment-only) return an empty document indexer instead,
    ///   allowing callers to throw a more descriptive error.
    public static func lazy(_ data: Data) throws -> XMLIndexer {
        let handler = SAXHandler()
        let parser = XMLParser(data: data)
        parser.delegate = handler
        let success = parser.parse()

        if !success && !handler.hadElementStart {
            // Parse "failed" only because there are no element nodes at all
            // (e.g. comment-only, or prolog-only document). Return an empty document
            // so callers can surface a meaningful XMLDeserializerError.
            return XMLIndexer(.document([]))
        }

        if !success, let error = handler.parseError ?? parser.parserError {
            // Structural error: mismatched tags, encoding issues, etc.
            throw error
        }

        return XMLIndexer(.document(handler.roots))
    }
}

// MARK: - SAX parser delegate

private final class SAXHandler: NSObject, XMLParserDelegate, @unchecked Sendable {
    private(set) var roots: [XMLNode] = []
    private(set) var parseError: Error?
    private(set) var hadElementStart = false

    // Each stack frame: (element name, attributes, accumulated children, accumulated text)
    private var stack: [(name: String, attributes: [String: String], children: [XMLNode], text: String)] = []

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        hadElementStart = true
        stack.append((name: elementName, attributes: attributeDict, children: [], text: ""))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1].text += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard let top = stack.popLast() else { return }
        let trimmed = top.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let node = XMLNode(
            name: top.name,
            text: trimmed.isEmpty ? nil : trimmed,
            attributes: top.attributes,
            children: top.children
        )
        if stack.isEmpty {
            roots.append(node)
        } else {
            stack[stack.count - 1].children.append(node)
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}
