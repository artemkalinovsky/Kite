//
//  MockURLProtocol.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class MockURLProtocol: URLProtocol {
    enum Error: Swift.Error {
        case missedXTestIDHeader
        case missedRequestHandler
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        do {
            guard let testID = request.value(forHTTPHeaderField: "X-Test-ID") else {
                throw Error.missedXTestIDHeader
            }
            guard let handler = MockURLHandlerStore.shared.handler(for: testID) else {
                throw Error.missedRequestHandler
            }
            MockURLHandlerStore.shared.removeHandler(for: testID)
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
