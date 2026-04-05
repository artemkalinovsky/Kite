import Foundation

public protocol ResponseDataDeserializer<Output> {
    associatedtype Output
    func deserialize(data: Data) async throws -> Output
}

public struct VoidDeserializer: ResponseDataDeserializer {
    public init() {}

    public func deserialize(data: Data) async throws {}
}

public struct RawDataDeserializer: ResponseDataDeserializer {
    public init() {}

    public func deserialize(data: Data) async throws -> Data { data }
}
