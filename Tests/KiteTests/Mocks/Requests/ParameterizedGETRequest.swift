import Foundation
import Kite

struct ParameterizedGETRequest: HTTPRequestProtocol {
    let id = UUID()
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String { "search" }
    var method: HTTPMethod { .get }
    var parameters: [String: any Sendable]? { ["page": 1, "limit": 20] }
    var headers: [String: String] { ["X-Test-ID": id.uuidString] }
}
