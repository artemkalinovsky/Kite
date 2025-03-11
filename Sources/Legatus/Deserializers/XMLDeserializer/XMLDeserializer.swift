import Foundation
import SWXMLHash

public enum XMLDeserializerError: Error {
    case xmlDeserializationFailed(String)
}

open class XMLDeserializer<T>: ResponseDeserializer<T> {
    public convenience init() {
        self.init(transform: { xmlObject -> T in
            if let xmlObject = xmlObject as? T {
                return xmlObject
            }
            throw XMLDeserializerError.xmlDeserializationFailed(
                "Wrong result type: \(type(of: xmlObject)). Expected \(T.self)"
            )
        })
    }
}

extension XMLDeserializer where T: XMLObjectDeserialization {
    public class func singleObjectDeserializer(keyPath path: String...) -> XMLDeserializer<T> {
        return XMLDeserializer<T>(transform: { xmlData in
            let xml = XMLHash.lazy(xmlData)
            return try xml[path].value()
        })
    }

    public class func collectionDeserializer(keyPath path: String...) -> XMLDeserializer<[T]> {
        return XMLDeserializer<[T]>(transform: { xmlData in
            let xml = XMLHash.lazy(xmlData)
            return try xml[path].value()
        })
    }
}
