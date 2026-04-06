import Foundation
import Kite

struct BadURLRequest: HTTPRequestProtocol {
    // Required by HTTPRequestProtocol; not used because `url` is overridden below.
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String { "/unused" }
    // Intentionally nil to exercise APIClient's `.badURL` branch.
    var url: URL? { nil }
}
