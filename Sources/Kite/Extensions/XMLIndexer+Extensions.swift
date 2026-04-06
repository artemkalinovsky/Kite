import Foundation
import SWXMLHash

extension XMLIndexer {
    subscript(keys: [String]) -> XMLIndexer {
        keys.reduce(self) { current, key in
            current[key]
        }
    }

    var documentRootElement: XMLIndexer? {
        guard let documentRoot = element else {
            return nil
        }

        guard let rootElement = documentRoot.children.compactMap({ $0 as? XMLHash.XMLElement }).first else {
            return nil
        }

        return XMLIndexer(rootElement)
    }
}
