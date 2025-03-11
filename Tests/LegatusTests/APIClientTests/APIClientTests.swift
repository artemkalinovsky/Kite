//
//  APIClientTests.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Testing
import Foundation
import Legatus

@Suite("APIClientTests")
struct APIClientTests {
    @Test("execute(request:) returns expected Data")
    func testExecuteHTTPRequestProtocol() async throws {
        let client = APIClient(urlSesion: makeMockSession())
        let expectedData = "Test Data".data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = FetchRawDataRequest()


        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) { request in
            return (expectedData, expectedResponse)
        }

        let data = try await client.execute(
            request: dummyRequest,
            deserializer: RawDataDeserializer(transform: { $0 })
        )

        #expect(data == expectedData)
    }

    @Test("execute(request:) deserializes response correctly for DeserializeableRequest")
    func testExecuteDeserializeableRequest() async throws {
        let client = APIClient(urlSesion: makeMockSession())
        let expectedData = JSONStubs.singlePerson.data(using: .utf8)!
        let expectedTestPerson = TestPerson.sample
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let dummyRequest = FetchSingleTestPersonRequest()

        await MockURLHandlerStore.shared.updateRequestHandler(for: dummyRequest.id.uuidString) { request in
            return (expectedData, expectedResponse)
        }

        let result = try await client.execute(request: dummyRequest)
        #expect(result == expectedTestPerson)
    }
}

private extension APIClientTests {
    func makeMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
