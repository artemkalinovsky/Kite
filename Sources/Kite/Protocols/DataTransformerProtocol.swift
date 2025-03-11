import Foundation

public protocol DataTransformerProtocol {
    associatedtype Output
    var transform: (Data) throws -> Output { get }
}
