//
//  MockURLProtocol.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
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
        Task {
            guard let testID = self.request.value(forHTTPHeaderField: "X-Test-ID") else {
                throw Error.missedXTestIDHeader
            }
            guard let handler = await MockURLHandlerStore.shared.handler(for: testID) else {
                throw Error.missedRequestHandler
            }
            do {
                let (data, response) = try handler(self.request)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.client?.urlProtocol(
                        self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    self.client?.urlProtocol(self, didLoad: data)
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.client?.urlProtocol(self, didFailWithError: error)
                }
            }
        }
    }

    override func stopLoading() {}
}
