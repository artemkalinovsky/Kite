//
//  AuthRequestProtocol.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

public protocol AuthRequestProtocol: HTTPRequestProtocol {
    var accessToken: String { get }
    var accessTokenPrefix: String { get }
}
