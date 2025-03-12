import Foundation
import UniformTypeIdentifiers

public class APIClient {
    private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func execute<T>(
        request: HTTPRequestProtocol,
        deserializer: ResponseDataDeserializer<T> = VoidDeserializer()
    ) async throws -> (T, URLResponse) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        for (field, value) in request.headers {
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
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        if let multipartFormData = request.multipartFormData, !multipartFormData.isEmpty {
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue(
                "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type"
            )

            var body = Data()
            for (key, fileURL) in multipartFormData {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                let filename = fileURL.lastPathComponent
                body.append(
                    "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!
                )
                let fileExtension = fileURL.pathExtension
                let contentType = UTType(filenameExtension: fileExtension)?.preferredMIMEType ?? "application/octet-stream"
                body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                let fileData = try Data(contentsOf: fileURL)
                body.append(fileData)
                body.append("\r\n".data(using: .utf8)!)
            }
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            urlRequest.httpBody = body
        }

        let (data, urlResponse) = try await urlSession.data(for: urlRequest)
        return (try await deserializer.deserialize(data: data), urlResponse)
    }

    public func execute<R: DeserializeableRequestProtocol>(request: R) async throws -> (R.ResponseType, URLResponse) {
        try await execute(request: request, deserializer: request.deserializer)
    }

    public func execute<R: AuthRequestProtocol & DeserializeableRequestProtocol>(request: R) async throws -> (R.ResponseType, URLResponse) {
        guard let authorizationHeader = request.headers["Authorization"], !authorizationHeader.isEmpty
        else {
            throw URLError(.userAuthenticationRequired)
        }

        return try await execute(request: request, deserializer: request.deserializer)
    }
}
