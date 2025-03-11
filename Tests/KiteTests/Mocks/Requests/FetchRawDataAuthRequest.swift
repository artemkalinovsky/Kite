import Foundation
import Kite

struct FetchRawDataAuthRequest: AuthRequestProtocol & DeserializeableRequest {
    let id: UUID
    let accessToken: String
    var baseURL: URL { URL(string: "https://example.com")! }
    var deserializer: ResponseDataDeserializer<Data> {
        RawDataDeserializer()
    }

    var headers: [String: String] {
        [
            "X-Test-ID": id.uuidString,
            "Authorization": "\(accessTokenPrefix) \(accessToken)"
        ]
    }

    init(accessToken: String, id: UUID = UUID()) {
        self.accessToken = accessToken
        self.id = id
    }
}
