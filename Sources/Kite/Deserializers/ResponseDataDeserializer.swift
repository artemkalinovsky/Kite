import Foundation

public class ResponseDataDeserializer<T> {
    private let transformer: DataTransformer<T>

    public init(transformer: DataTransformer<T>) {
        self.transformer = transformer
    }

    public func deserialize(data: Data) async throws -> T {
        return try transformer.transform(data)
    }
}

public class VoidDeserializer: ResponseDataDeserializer<Void> {
    public init() {
        super.init(transformer: DataTransformer())
    }

    @available(*, unavailable, message: "Use the default initializer instead")
    override public init(transformer: DataTransformer<Void> = .init()) {
        fatalError("This initializer is unavailable. Use the default initializer instead.")
    }
}

public class RawDataDeserializer: ResponseDataDeserializer<Data> {
    public init() {
        super.init(transformer: DataTransformer())
    }

    @available(*, unavailable, message: "Use the default initializer instead")
    override public init(transformer: DataTransformer<Data> = .init()) {
        fatalError("This initializer is unavailable. Use the default initializer instead.")
    }
}
