//
//  AuthRequestProtocol+Extensions.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation

public extension AuthRequestProtocol {
    var accessTokenPrefix: String {
        "Bearer"
    }

    func headers() throws -> [String: String] {
        guard let accessToken = accessToken else {
            throw AuthRequestError.accessTokenIsNil
        }
        return [
            "Authorization": "\(accessTokenPrefix) \(accessToken)",
            "accept-language": Locale.current.identifier
        ]
    }
}
