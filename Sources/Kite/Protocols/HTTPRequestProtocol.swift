import Foundation

public protocol HTTPRequestProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    var method: HTTPMethod { get }
    var multipartFormData: [String: URL]? { get }
    var headers: [String: String] { get }
}
