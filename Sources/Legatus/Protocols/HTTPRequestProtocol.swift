import Foundation

public protocol HTTPRequestProtocol {
    var fullPath: String? { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    var method: HTTPMethod { get }
    var multipartFormData: [String: URL]? { get }
    func headers() throws -> [String: String]
}
