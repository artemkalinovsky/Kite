//
//  DeserializeableRequestProtocol.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

public protocol DeserializeableRequestProtocol: HTTPRequestProtocol {
    associatedtype ResponseType
    var deserializer: ResponseDataDeserializer<ResponseType> { get }
}
