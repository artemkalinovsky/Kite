import Foundation

public extension HTTPRequestProtocol {
    var fullPath: String? {
        nil
    }

    var path: String {
        ""
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: [String: Any]? {
        nil
    }

    func headers() throws -> [String: String] {
        [:]
    }

    var multipartFormData: [String: URL]? {
        nil
    }

   func configureHTTPHeaders() -> Result<[String: String], Error> {
       var headers = [String: String]()
       do {
           headers = try self.headers()
       } catch {
           return .failure(error)
       }
       return .success(headers)
   }

    func configurePath(baseUrl: URL) -> String {
        var requestPath = baseUrl.appendingPathComponent(self.path).absoluteString
        if let fullPath = self.fullPath, !fullPath.isEmpty {
            requestPath = fullPath
        }
        return requestPath
    }
}
