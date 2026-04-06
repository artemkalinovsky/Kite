//
//  MockURLHandlerStore.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class MockURLHandlerStore: @unchecked Sendable {
    private typealias Handler = @Sendable (URLRequest) throws -> (Data, URLResponse)
    static let shared = MockURLHandlerStore()
    private init() {}
    private var handlers: [String: Handler] = [:]
    private let lock = NSLock()

    func updateRequestHandler(
        for id: String,
        requestHandler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse)
    ) {
        lock.withLock { handlers[id] = requestHandler }
    }

    func handler(for id: String) -> (@Sendable (URLRequest) throws -> (Data, URLResponse))? {
        lock.withLock { handlers[id] }
    }

    func removeHandler(for id: String) {
        lock.withLock { handlers.removeValue(forKey: id) }
    }
}
