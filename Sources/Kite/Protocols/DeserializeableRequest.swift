//
//  DeserializeableRequest.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

public protocol DeserializeableRequest: HTTPRequestProtocol {
    associatedtype ResponseType
    var deserializer: ResponseDeserializer<ResponseType> { get }
}
