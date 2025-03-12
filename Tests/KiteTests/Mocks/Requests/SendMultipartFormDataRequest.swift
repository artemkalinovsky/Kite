import Foundation
import Kite

struct SendMultipartFormDataRequest: AuthRequestProtocol & DeserializeableRequestProtocol {
    let id: UUID
    let accessToken: String
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String { "/upload" }
    var method: HTTPMethod { .post }
    let multipartFormData: [String: URL]?

    var headers: [String: String] {
        [
            "X-Test-ID": id.uuidString,
            "Authorization": "\(accessTokenPrefix) \(accessToken)"
        ]
    }

    var deserializer: ResponseDataDeserializer<URL> {
        JSONDeserializer<URL>.singleObjectDeserializer(keyPath: "logo_url")
    }

    init(accessToken: String, multipartFormData: [String: URL], id: UUID = UUID()) {
        self.accessToken = accessToken
        self.multipartFormData = multipartFormData
        self.id = id
    }
}
