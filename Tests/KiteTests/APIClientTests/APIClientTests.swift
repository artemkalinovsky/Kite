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
