import Foundation
import SWXMLHash

extension XMLIndexer {
    subscript(keys: [String]) -> XMLIndexer {
        keys.reduce(self) { current, key in
            current[key]
        }
    }
}

