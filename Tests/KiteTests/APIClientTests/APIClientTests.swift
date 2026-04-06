//
//  APIClientTests.swift
//  Kite
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Kite
import Testing

@Suite("APIClientTests")
struct APIClientTests {
    @Test("execute(request:) returns expected raw data")
    func testExecuteReturnsExpectedRawData() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedData = try #require("Test Data".data(using: .utf8))
        let expectedURL = try makeURL("https://example.com/test")
        let expectedResponse = try makeResponse(url: expectedURL)

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
        let expectedData = try #require("Authenticated Data".data(using: .utf8))
        let expectedURL = try makeURL("https://example.com/auth")
        let expectedResponse = try makeResponse(url: expectedURL)

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
        let expectedData = try #require(JSONStubs.singlePerson.data(using: .utf8))
        let expectedTestPerson = TestPerson.sample
        let expectedURL = try makeURL("https://example.com/test")
        let expectedResponse = try makeResponse(url: expectedURL)

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
        let expectedData = try #require(XMLStubs.singlePerson.data(using: .utf8))
        let expectedTestPerson = TestPerson.sample
        let expectedURL = try makeURL("https://example.com/test")
        let expectedResponse = try makeResponse(url: expectedURL)

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

            let url = try #require(request.url)
            let response = try makeResponse(url: url)
            return (Data(), response)
        }

        _ = try await client.execute(request: dummyRequest)
    }

    @Test("execute(request:) throws unacceptableStatusCode on non-2xx response")
    func testExecuteThrowsOnHTTPErrorStatusCode() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let dummyRequest = FetchRawDataRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            _ in
            let url = try makeURL("https://example.com/test")
            let response = try makeResponse(url: url, statusCode: 404)
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

            let response = try makeResponse(url: url)
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

            let body = try requestBody(from: request)

            let json = try #require(
                JSONSerialization.jsonObject(with: body) as? [String: Any]
            )
            #expect(json["name"] as? String == "John")
            #expect(json["age"] as? Int == 30)

            let url = try #require(request.url)
            let response = try makeResponse(url: url)
            return (Data(), response)
        }

        _ = try await client.execute(request: dummyRequest, deserializer: VoidDeserializer())
    }

    @Test("execute(request:) handles multipart form data correctly")
    func testExecuteHandlesMultipartFormDataCorrectly() async throws {
        let client = APIClient(urlSession: makeMockSession())
        let expectedLogoURL = try makeURL("https://example.com/swift_logo.png")
        let expectedData = """
        {
            "logo_url": "\(expectedLogoURL.absoluteString)"
        }
        """
        let encodedExpectedData = try #require(expectedData.data(using: .utf8))
        let uploadURL = try makeURL("https://example.com/upload")
        let expectedResponse = try makeResponse(url: uploadURL)
        let logoFileURL = try #require(
            Bundle.module.url(forResource: "swift_logo", withExtension: "png")
        )

        let dummyRequest = SendMultipartFormDataRequest(
            accessToken: UUID().uuidString,
            multipartFormData: [
                "file": logoFileURL
            ]
        )

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) {
            request in
            let contentType = try #require(request.value(forHTTPHeaderField: "Content-Type"))
            #expect(contentType.contains("multipart/form-data; boundary="))

            let body = try requestBody(from: request)
            let expectedFileData = try Data(contentsOf: logoFileURL)

            #expect(body.range(of: Data("filename=\"swift_logo.png\"".utf8)) != nil)
            #expect(body.range(of: expectedFileData) != nil)

            return (encodedExpectedData, expectedResponse)
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

    fileprivate func makeURL(_ string: String) throws -> URL {
        try #require(URL(string: string))
    }

    fileprivate func requestBody(from request: URLRequest) throws -> Data {
        if let httpBody = request.httpBody {
            return httpBody
        }

        guard let stream = request.httpBodyStream else {
            throw URLError(.cannotParseResponse)
        }

        stream.open()
        defer { stream.close() }

        var data = Data()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        defer { buffer.deallocate() }

        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: 1024)
            if read > 0 {
                data.append(buffer, count: read)
            } else {
                break
            }
        }

        return data
    }

    fileprivate func makeResponse(url: URL, statusCode: Int = 200) throws -> HTTPURLResponse {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        return try #require(response)
    }
}
