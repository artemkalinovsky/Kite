//
//  APIClientTests.swift
//  Kite
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Foundation
import Kite
import Testing

@Suite("APIClientTests")
struct APIClientTests {
    @Test("execute(request:) returns expected raw data")
    func testExecuteReturnsExpectedRawData() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedData = "Test Data".data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = FetchRawDataRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            return (expectedData, expectedResponse)
        }

        let (data, _) = try await client.execute(
            request: dummyRequest,
            deserializer: RawDataDeserializer()
        )

        #expect(data == expectedData)
    }

    @Test("execute(request:) handles authenticated request correctly")
    func testExecuteHandlesAuthenticatedRequestCorrectly() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedData = "Authenticated Data".data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/auth")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = FetchRawDataAuthRequest(accessToken: UUID().uuidString)

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            return (expectedData, expectedResponse)
        }

        let (data, _) = try await client.execute(
            request: dummyRequest,
            deserializer: RawDataDeserializer()
        )

        #expect(data == expectedData)
    }

    @Test("execute(request:) deserializes JSON response correctly")
    func testExecuteDeserializesJSONResponseCorrectly() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedData = JSONStubs.singlePerson.data(using: .utf8)!
        let expectedTestPerson = TestPerson.sample
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = FetchSingleTestPersonJSONRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            return (expectedData, expectedResponse)
        }

        let (result, _) = try await client.execute(request: dummyRequest)
        #expect(result == expectedTestPerson)
    }

    @Test("execute(request:) deserializes XML response correctly")
    func testExecuteDeserializesXMLResponseCorrectly() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedData = XMLStubs.singlePerson.data(using: .utf8)!
        let expectedTestPerson = TestPerson.sample
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = FetchSingleTestPersonXMLRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            return (expectedData, expectedResponse)
        }

        let (result, _) = try await client.execute(request: dummyRequest)
        #expect(result == expectedTestPerson)
    }

    @Test("execute(request:) throws userAuthenticationRequired when auth header is empty")
    func testExecuteThrowsOnEmptyAuthToken() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let dummyRequest = EmptyAuthRequest()

        await #expect(throws: URLError.self) {
            _ = try await client.execute(request: dummyRequest)
        }
    }

    @Test("execute(request:) sends authorizationHeaders when request headers contain stale authorization")
    func testExecutePrefersAuthorizationHeadersOverConflictingRequestHeader() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let token = UUID().uuidString
        let dummyRequest = FetchRawDataAuthRequest(
            accessToken: token,
            extraHeaders: ["Authorization": "Bearer stale-token"]
        )

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            request in
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer \(token)")

            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (Data(), response)
        }

        _ = try await client.execute(request: dummyRequest)
    }

    @Test("execute(request:) throws badURL when url is nil")
    func testExecuteThrowsOnBadURL() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let dummyRequest = BadURLRequest()

        await #expect(throws: URLError.self) {
            _ = try await client.execute(
                request: dummyRequest,
                deserializer: VoidDeserializer()
            )
        }
    }

    @Test("execute(request:) throws unacceptableStatusCode on non-2xx response")
    func testExecuteThrowsOnHTTPErrorStatusCode() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let dummyRequest = FetchRawDataRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com/test")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (Data(), response)
        }

        await #expect(throws: APIClientError.self) {
            _ = try await client.execute(
                request: dummyRequest,
                deserializer: RawDataDeserializer()
            )
        }
    }

    @Test("execute(request:) encodes GET parameters as query string")
    func testExecuteEncodesGETParametersAsQueryString() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let dummyRequest = ParameterizedGETRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            request in
            let url = try #require(request.url)
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            let queryItems = try #require(components.queryItems)
            #expect(queryItems.contains(URLQueryItem(name: "page", value: "1")))
            #expect(queryItems.contains(URLQueryItem(name: "limit", value: "20")))
            #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
            #expect(request.httpBody == nil)

            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (Data(), response)
        }

        _ = try await client.execute(request: dummyRequest, deserializer: VoidDeserializer())
    }

    @Test("execute(request:) encodes POST parameters as JSON body")
    func testExecuteEncodesPOSTParametersAsJSONBody() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let dummyRequest = ParameterizedPOSTRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            request in
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

            // URLSession may move httpBody to httpBodyStream in URLProtocol
            let body: Data
            if let httpBody = request.httpBody {
                body = httpBody
            } else if let stream = request.httpBodyStream {
                stream.open()
                var data = Data()
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
                defer { buffer.deallocate() }
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: 1024)
                    if read > 0 { data.append(buffer, count: read) }
                    else { break }
                }
                stream.close()
                body = data
            } else {
                throw URLError(.cannotParseResponse)
            }

            let json = try #require(
                JSONSerialization.jsonObject(with: body) as? [String: Any]
            )
            #expect(json["name"] as? String == "John")
            #expect(json["age"] as? Int == 30)

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (Data(), response)
        }

        _ = try await client.execute(request: dummyRequest, deserializer: VoidDeserializer())
    }

    @Test("execute(request:) handles multipart form data correctly")
    func testExecuteHandlesMultipartFormDataCorrectly() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedLogoURL = URL(string: "https://example.com/swift_logo.png")!
        let expectedData = """
        {
            "logo_url": "\(expectedLogoURL.absoluteString)"
        }
        """
        .data(using: .utf8)!

        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/upload")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = SendMultipartFormDataRequest(
            accessToken: UUID().uuidString,
            multipartFormData: [
                "file": Bundle.module.url(forResource: "swift_logo", withExtension: "png")!
            ]
        )

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            return (expectedData, expectedResponse)
        }

        let (logoURL, urlResponse) = try await client.execute(request: dummyRequest)

        let httpURLResponse = try #require(urlResponse as? HTTPURLResponse)
        #expect(httpURLResponse.statusCode == 200)
        #expect(logoURL == expectedLogoURL)
    }
}

extension APIClientTests {
    fileprivate func makeMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
