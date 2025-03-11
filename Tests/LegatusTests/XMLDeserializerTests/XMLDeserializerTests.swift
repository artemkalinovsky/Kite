//
//  XMLDeserializerTests.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Testing
import SWXMLHash
import Legatus

@Suite("XMLDeserializerTests")
struct XMLDeserializerTests {
    @Test("Single object deserializer decodes correctly")
    func testSingleObjectDeserializer() async throws {
        let data = XMLStubs.singlePerson.data(using: .utf8)!
        let deserializer = XMLDeserializer<TestPerson>.singleObjectDeserializer(keyPath: "response", "person")
        let person = try await deserializer.deserialize(data: data)

        let expected = TestPerson(name: "John", age: 30)
        #expect(person == expected)
    }

    @Test("Collection deserializer decodes correctly")
    func testCollectionDeserializer() async throws {
        let data = XMLStubs.personCollection.data(using: .utf8)!
        let deserializer = XMLDeserializer<TestPerson>.collectionDeserializer(keyPath: "response", "persons", "person")
        let persons = try await deserializer.deserialize(data: data)
        let expected = [
            TestPerson(name: "John", age: 30),
            TestPerson(name: "Jane", age: 25)
        ]
        #expect(persons == expected)
    }

    @Test("Single object deserializer fails on invalid XML")
    func testSingleObjectDeserializerFailure() async {
        let invalidXML = "<invalid><xml></invalid>"
        let data = invalidXML.data(using: .utf8)!
        let deserializer = XMLDeserializer<TestPerson>.singleObjectDeserializer(keyPath: "response", "person")

        await #expect(throws: (any Error).self) {
            _ = try await deserializer.deserialize(data: data)
        }
    }
}
