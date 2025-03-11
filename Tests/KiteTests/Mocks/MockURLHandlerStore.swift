//
//  MockURLHandlerStore.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation

final actor MockURLHandlerStore {
    private typealias Handler = @Sendable (URLRequest) throws -> (Data, URLResponse)
    static let shared = MockURLHandlerStore()
    private init() {}
    private var handlers: [String: Handler] = [:]
    func updateRequestHandler(
        for id: String,
        requestHandler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse)
    ) {
        handlers[id] = requestHandler
    }

    func handler(for id: String) -> (@Sendable (URLRequest) throws -> (Data, URLResponse))? {
        handlers[id]
    }

    func removeHandler(for id: String) {
        handlers.removeValue(forKey: id)
    }
}
