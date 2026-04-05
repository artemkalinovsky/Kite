//
//  XMLDeserializerTests.swift
//  Kite
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Testing
import SWXMLHash
import Kite

@Suite("XMLDeserializerTests")
struct XMLDeserializerTests {
    @Test("Single object deserializer decodes correctly")
    func testSingleObjectDeserializer() throws {
        let data = try #require(XMLStubs.singlePerson.data(using: .utf8))
        let deserializer = XMLDeserializer<TestPerson>.singleObjectDeserializer(keyPath: "response", "person")
        let person = try deserializer.deserialize(data: data)

        let expected = TestPerson(name: "John", age: 30)
        #expect(person == expected)
    }

    @Test("Collection deserializer decodes correctly")
    func testCollectionDeserializer() throws {
        let data = try #require(XMLStubs.personCollection.data(using: .utf8))
        let deserializer = XMLDeserializer<TestPerson>.collectionDeserializer(keyPath: "response", "persons", "person")
        let persons = try deserializer.deserialize(data: data)
        let expected = [
            TestPerson(name: "John", age: 30),
            TestPerson(name: "Jane", age: 25)
        ]
        #expect(persons == expected)
    }

    @Test("Single object deserializer fails on invalid XML")
    func testSingleObjectDeserializerFailure() throws {
        let data = try #require("<invalid><xml></invalid>".data(using: .utf8))
        let deserializer = XMLDeserializer<TestPerson>.singleObjectDeserializer(keyPath: "response", "person")

        #expect(throws: (any Error).self) {
            _ = try deserializer.deserialize(data: data)
        }
    }
}
