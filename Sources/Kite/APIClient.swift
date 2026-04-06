import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Dispatch

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
        try await executeRequest(request: request, deserializer: deserializer)
    }

    private func executeRequest<T>(
        request: HTTPRequestProtocol,
        deserializer: any ResponseDataDeserializer<T>
    ) async throws -> (T, URLResponse) {
        let url = request.baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        let allHeaders = request.headers.merging(try authorizationHeaders(for: request)) { _, additional in
            additional
        }
        for (field, value) in allHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }

        if let multipartFormData = request.multipartFormData, !multipartFormData.isEmpty {
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue(
                "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type"
            )

            var body = Data()

            if let parameters = request.parameters {
                for (key, value) in parameters {
                    body.append(Data("--\(boundary)\r\n".utf8))
                    body.append(
                        Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8)
                    )
                    body.append(Data("\(value)\r\n".utf8))
                }
            }

            for (key, fileURL) in multipartFormData {
                body.append(Data("--\(boundary)\r\n".utf8))
                let filename = fileURL.lastPathComponent
                body.append(
                    Data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".utf8)
                )
                let fileExtension = fileURL.pathExtension
                let contentType = MIMEType.from(fileExtension: fileExtension)
                body.append(Data("Content-Type: \(contentType)\r\n\r\n".utf8))
                let fileData = try await readFileData(from: fileURL)
                body.append(fileData)
                body.append(Data("\r\n".utf8))
            }
            body.append(Data("--\(boundary)--\r\n".utf8))
            urlRequest.httpBody = body
        } else if let parameters = request.parameters {
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
        try await executeRequest(request: request, deserializer: request.deserializer)
    }

    public func execute<R: AuthRequestProtocol & DeserializeableRequestProtocol>(request: R) async throws -> (R.ResponseType, URLResponse) {
        try await executeRequest(request: request, deserializer: request.deserializer)
    }

    private static let fileReadQueue = DispatchQueue(
        label: "Kite.APIClient.FileReadQueue",
        qos: .utility,
        attributes: .concurrent
    )

    // Bridge synchronous file I/O onto a utility queue so multipart assembly
    // does not block the caller's async executor while reading large files.
    private func readFileData(from fileURL: URL) async throws -> Data {
        try Task.checkCancellation()

        return try await withCheckedThrowingContinuation { continuation in
            Self.fileReadQueue.async {
                do {
                    continuation.resume(returning: try Data(contentsOf: fileURL))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func authorizationHeaders(for request: HTTPRequestProtocol) throws -> [String: String] {
        guard let authRequest = request as? any AuthRequestProtocol else {
            return [:]
        }

        guard
            let headerValue = authorizationHeaderValue(in: authRequest.authorizationHeaders)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !headerValue.isEmpty
        else {
            throw URLError(.userAuthenticationRequired)
        }

        return authRequest.authorizationHeaders
    }

    private func authorizationHeaderValue(in headers: [String: String]) -> String? {
        headers.first { key, _ in
            key.caseInsensitiveCompare("Authorization") == .orderedSame
        }?.value
    }
}
