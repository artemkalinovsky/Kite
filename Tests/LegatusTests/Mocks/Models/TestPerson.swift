//
//  TestPerson.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

import SWXMLHash

struct TestPerson: Codable, Equatable, XMLObjectDeserialization {
    let name: String
    let age: Int

    static let sample = TestPerson(name: "John", age: 30)

    static func deserialize(_ node: XMLIndexer) throws -> Self {
        return try Self(
            name: node["name"].value(),
            age: node["age"].value()
        )
    }
}
