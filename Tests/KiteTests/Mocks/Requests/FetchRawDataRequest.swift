//
//  FetchRawDataRequest.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation
import Kite

struct FetchRawDataRequest: HTTPRequestProtocol {
    var fullPath: String? { "https://example.com/test" }
    var path: String { "https://example.com/test" }
    var parameters: [String: Any]? { nil }
    var method: HTTPMethod { .get }
    var multipartFormData: [String: URL]? { nil }
    func headers() throws -> [String : String] { return ["X-Test-ID": id.uuidString] }

    let id = UUID()
}
