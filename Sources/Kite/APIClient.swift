import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum APIClientError: LocalizedError {
    case unacceptableStatusCode(statusCode: Int, response: HTTPURLResponse, data: Data)

    public var errorDescription: String? {
        switch self {
        case .unacceptableStatusCode(let statusCode, _, _):
            "Request failed with status code \(statusCode)."
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public final class APIClient: Sendable {
    private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func execute<T>(
        request: HTTPRequestProtocol,
        deserializer: any ResponseDataDeserializer<T> = VoidDeserializer()
    ) async throws -> (T, URLResponse) {
        try await execute(
            request: request,
            deserializer: deserializer,
            additionalHeaders: [:]
        )
    }

    private func execute<T>(
        request: HTTPRequestProtocol,
        deserializer: any ResponseDataDeserializer<T>,
        additionalHeaders: [String: String]
    ) async throws -> (T, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        let allHeaders = request.headers.merging(additionalHeaders) { _, additional in additional }
        for (field, value) in allHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }

        if let parameters = request.parameters {
            if request.method == .get {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
                if let newURL = components?.url {
                    urlRequest.url = newURL
                }
            } else {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }

        if let multipartFormData = request.multipartFormData, !multipartFormData.isEmpty {
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue(
                "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type"
            )

            var body = Data()
            for (key, fileURL) in multipartFormData {
                body.append(Data("--\(boundary)\r\n".utf8))
                let filename = fileURL.lastPathComponent
                body.append(
                    Data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".utf8)
                )
                let fileExtension = fileURL.pathExtension
                let contentType = MIMEType.from(fileExtension: fileExtension)
                body.append(Data("Content-Type: \(contentType)\r\n\r\n".utf8))
                let fileData = try Data(contentsOf: fileURL)
                body.append(fileData)
                body.append(Data("\r\n".utf8))
            }
            body.append(Data("--\(boundary)--\r\n".utf8))
            urlRequest.httpBody = body
        }

        let (data, urlResponse) = try await urlSession.data(for: urlRequest)

        if let httpResponse = urlResponse as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw APIClientError.unacceptableStatusCode(
                statusCode: httpResponse.statusCode,
                response: httpResponse,
                data: data
            )
        }

        return (try deserializer.deserialize(data: data), urlResponse)
    }

    public func execute<R: DeserializeableRequestProtocol>(request: R) async throws -> (R.ResponseType, URLResponse) {
        try await execute(request: request, deserializer: request.deserializer)
    }

    public func execute<R: AuthRequestProtocol & DeserializeableRequestProtocol>(request: R) async throws -> (R.ResponseType, URLResponse) {
        let authorizationHeader = request.authorizationHeaders["Authorization"]
        guard let authorizationHeader, !authorizationHeader.isEmpty
        else {
            throw URLError(.userAuthenticationRequired)
        }

        return try await execute(
            request: request,
            deserializer: request.deserializer,
            additionalHeaders: request.authorizationHeaders
        )
    }
}
