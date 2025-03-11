import Foundation

public final class APIClient {
    private let urlSesion: URLSession

    public init(urlSesion: URLSession = URLSession.shared) {
        self.urlSesion = urlSesion
    }

    public func execute<T>(request: HTTPRequestProtocol, deserializer: ResponseDeserializer<T>) async throws -> T {
        guard let url = URL(string: request.fullPath ?? request.path) else {
            throw URLError(.badURL)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        let headers = try request.headers()
        for (field, value) in headers {
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
            throw URLError(.unsupportedURL)
        }

        let (data, _) = try await urlSesion.data(for: urlRequest)

        return try await deserializer.deserialize(data: data)
    }

    public func execute<R: DeserializeableRequest>(request: R) async throws -> R.ResponseType {
        try await execute(request: request, deserializer: request.deserializer)
    }
}
