import Foundation

public enum JSONDeserializerError: Error {
    case jsonDeserializableInitFailed(String)
}

public class JSONDeserializer<T>: ResponseDataDeserializer<T> {
    public convenience init() {
        self.init(
            transformer: DataTransformer(
                transform: { data -> T in
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    guard let object = jsonObject as? T else {
                        throw JSONDeserializerError.jsonDeserializableInitFailed(
                            "Wrong result type: \(type(of: jsonObject)). Expected \(T.self)"
                        )
                    }
                    return object
                }
            )
        )
    }
}

extension JSONDeserializer where T: Decodable {
    public class func singleObjectDeserializer(keyPath path: String...) -> JSONDeserializer<T> {
        JSONDeserializer<T>(
            transformer: DataTransformer(
                transform: { data in
                    let jsonDecoder = JSONDecoder()
                    do {
                        if path.isEmpty {
                            return try jsonDecoder.decode(T.self, from: data)
                        } else {
                            return try jsonDecoder.decode(T.self, from: data, keyPath: path.joined(separator: "."))
                        }
                    } catch {
                        throw JSONDeserializerError.jsonDeserializableInitFailed(
                            "Failed to create \(T.self) object from path \(path)."
                        )
                    }
                }
            )
        )
    }

    public class func collectionDeserializer(keyPath path: String...) -> JSONDeserializer<[T]> {
        JSONDeserializer<[T]>(
            transformer: DataTransformer(
                transform: { data in
                    let jsonDecoder = JSONDecoder()
                    do {
                        if path.isEmpty {
                            return try jsonDecoder.decode([T].self, from: data)
                        } else {
                            return try jsonDecoder.decode([T].self, from: data, keyPath: path.joined(separator: "."))
                        }
                    } catch {
                        throw JSONDeserializerError.jsonDeserializableInitFailed(
                            "Failed to create array of \(T.self) objects."
                        )
                    }
                }
            )
        )
    }
}
