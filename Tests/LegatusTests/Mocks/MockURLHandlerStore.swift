//
//  MockURLHandlerStore.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation

final actor MockURLHandlerStore {
    static let shared = MockURLHandlerStore()
    private init() {}
    private var handlers: [String: (@Sendable (URLRequest) throws -> (Data, URLResponse))] = [:]

    func updateRequestHandler(for id: String, _ handler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse)) {
        handlers[id] = handler
    }

    func handler(for id: String) -> (@Sendable (URLRequest) throws -> (Data, URLResponse))? {
        return handlers[id]
    }

    func removeHandler(for id: String) {
        handlers.removeValue(forKey: id)
    }
}
