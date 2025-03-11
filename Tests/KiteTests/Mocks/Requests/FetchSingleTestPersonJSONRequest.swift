//
//  FetchSingleTestPersonJSONRequest.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import Foundation
import Kite

struct FetchSingleTestPersonJSONRequest: DeserializeableRequest {
    var baseURL: URL { URL(string: "https://example.com")! }
    var path: String { "test" }
    var headers: [String: String] { ["X-Test-ID": id.uuidString] }

    let id = UUID()

    var deserializer: ResponseDataDeserializer<TestPerson> {
        JSONDeserializer<TestPerson>.singleObjectDeserializer()
    }
}
