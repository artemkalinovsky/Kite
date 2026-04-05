import Foundation
import Kite

struct FetchRawDataAuthRequest: AuthRequestProtocol & DeserializeableRequestProtocol {
    let id: UUID
    let accessToken: String
    let extraHeaders: [String: String]
    var baseURL: URL { URL(string: "https://example.com")! }
    var deserializer: any ResponseDataDeserializer<Data> {
        RawDataDeserializer()
    }

    var headers: [String: String] {
        ["X-Test-ID": id.uuidString].merging(extraHeaders) { _, extra in extra }
    }

    init(
        accessToken: String,
        id: UUID = UUID(),
        extraHeaders: [String: String] = [:]
    ) {
        self.accessToken = accessToken
        self.id = id
        self.extraHeaders = extraHeaders
    }
}
