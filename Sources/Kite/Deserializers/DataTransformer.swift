//
//  DataTransformer.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation

public struct DataTransformer<O>: DataTransformerProtocol {
    public let transform: (Data) throws -> O

    public init(transform: @escaping (Data) throws -> O) {
        self.transform = transform
    }
}

extension DataTransformer where O == Void {
    public init() {
        self.transform = { _ in }
    }

    @available(*, unavailable, message: "Use the default initializer instead")
    public init(transform: @escaping (Data) throws -> O) {
        fatalError("This initializer is unavailable. Use the default initializer instead.")
    }
}

extension DataTransformer where O == Data {
    public init() {
        self.transform = { $0 }
    }

    @available(*, unavailable, message: "Use the default initializer instead")
    public init(transform: @escaping (Data) throws -> O) {
        fatalError("This initializer is unavailable. Use the default initializer instead.")
    }
}
