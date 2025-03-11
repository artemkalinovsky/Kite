import Foundation

open class ResponseDeserializer<T> {
    public typealias Transform = (Data) throws -> T
    private let transform: Transform

    public init(transform: @escaping Transform) {
        self.transform = transform
    }

    open func deserialize(data: Data) async throws -> T {
        return try transform(data)
    }
}

public class EmptyDeserializer: ResponseDeserializer<Void> {
    public override func deserialize(data: Data) async throws -> Void {
        ()
    }
}

public class RawDataDeserializer: ResponseDeserializer<Data> {
    public override func deserialize(data: Data) async throws -> Data {
        data
    }
}
