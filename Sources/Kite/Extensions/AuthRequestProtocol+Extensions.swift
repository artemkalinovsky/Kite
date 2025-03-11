//
//  AuthRequestProtocol+Extensions.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation

extension AuthRequestProtocol {
    public var accessTokenPrefix: String {
        "Bearer"
    }

    public var headers: [String: String] {
        [
            "Authorization": "\(accessTokenPrefix) \(accessToken)"
        ]
    }
}
