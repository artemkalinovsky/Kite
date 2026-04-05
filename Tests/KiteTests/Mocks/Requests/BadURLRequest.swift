import Foundation
import Kite

struct BadURLRequest: HTTPRequestProtocol {
    var baseURL: URL { URL(string: "https://example.com")! }
    var url: URL? { nil }
}
