import Foundation
import Kite

struct ParameterizedPOSTRequest: HTTPRequestProtocol {
    let id = UUID()
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String { "persons" }
    var method: HTTPMethod { .post }
    var parameters: [String: any Sendable]? { ["name": "John", "age": 30] }
    var headers: [String: String] { ["X-Test-ID": id.uuidString] }
}
