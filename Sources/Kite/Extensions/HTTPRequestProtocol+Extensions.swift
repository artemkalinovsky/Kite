import Foundation

extension HTTPRequestProtocol {
    public var url: URL? {
        baseURL.appendingPathComponent(self.path)
    }

    public var path: String {
        ""
    }

    public var method: HTTPMethod {
        .get
    }

    public var parameters: [String: any Sendable]? {
        nil
    }

    public var headers: [String: String] {
        [:]
    }

    public var multipartFormData: [String: URL]? {
        nil
    }
}
