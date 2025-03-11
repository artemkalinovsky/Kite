import Foundation

public class APIClient {
    private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func execute<T>(request: HTTPRequestProtocol, deserializer: ResponseDataDeserializer<T> = VoidDeserializer()) async throws -> T {
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
            throw URLError(.unsupportedURL)
        }

        let (data, _) = try await urlSession.data(for: urlRequest)

        return try await deserializer.deserialize(data: data)
    }

    public func execute<R: DeserializeableRequest>(request: R) async throws -> R.ResponseType {
        try await execute(request: request, deserializer: request.deserializer)
    }

    public func execute<R: AuthRequestProtocol & DeserializeableRequest>(request: R) async throws -> R.ResponseType {
        guard let authorizationHeader = request.headers["Authorization"], !authorizationHeader.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }

        return try await execute(request: request, deserializer: request.deserializer)
    }
}
