//
//  AuthRequestProtocol.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

public enum AuthRequestError: Error {
    case accessTokenIsNil
}

public protocol AuthRequestProtocol: HTTPRequestProtocol {
    var accessToken: String? { get set }
    var accessTokenPrefix: String { get }
}
