import Foundation
import Kite

struct EmptyAuthRequest: AuthRequestProtocol & DeserializeableRequestProtocol {
    let id = UUID()
    var baseURL: URL { URL(string: "https://example.com")! }
    var accessToken: String { "" }
    var authorizationHeaders: [String: String] { ["Authorization": ""] }
    var deserializer: any ResponseDataDeserializer<Data> { RawDataDeserializer() }
    var headers: [String: String] { ["X-Test-ID": id.uuidString] }
}
