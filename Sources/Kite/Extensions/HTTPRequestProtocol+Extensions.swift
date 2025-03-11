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

    public var parameters: [String: Any]? {
        nil
    }

    public var headers: [String: String] {
        [:]
    }

    public var multipartFormData: [String: URL]? {
        nil
    }
}
