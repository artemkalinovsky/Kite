import Foundation

public protocol HTTPRequestProtocol {
    var baseURL: URL { get }
    var url: URL? { get }
    var path: String { get }
    var parameters: [String: any Sendable]? { get }
    var method: HTTPMethod { get }
    var multipartFormData: [String: URL]? { get }
    var headers: [String: String] { get }
}
