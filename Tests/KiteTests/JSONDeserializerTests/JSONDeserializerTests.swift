//
//  JSONDeserializerTests.swift
//  Kite
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Testing
import Kite

@Suite("JSONDeserializerTests")
struct JSONDeserializerTests {
    @Test("Single object deserializer decodes correctly")
    func testSingleObjectDeserializer() throws {
        let data = try #require(JSONStubs.singlePerson.data(using: .utf8))
        let deserializer = JSONDeserializer<TestPerson>.singleObjectDeserializer()
        let person = try deserializer.deserialize(data: data)
        #expect(person == TestPerson(name: "John", age: 30))
    }

    @Test("Collection deserializer decodes correctly")
    func testCollectionDeserializer() throws {
        let data = try #require(JSONStubs.personCollection.data(using: .utf8))
        let deserializer = JSONDeserializer<TestPerson>.collectionDeserializer()
        let persons = try deserializer.deserialize(data: data)
        #expect(persons == [
            TestPerson(name: "John", age: 30),
            TestPerson(name: "Jane", age: 25)
        ])
    }

    @Test("Single object deserializer fails on invalid JSON")
    func testSingleObjectDeserializerFailure() throws {
        let invalidJSON = try #require("Not a JSON".data(using: .utf8))
        let deserializer = JSONDeserializer<TestPerson>.singleObjectDeserializer()
        #expect(throws: (any Error).self) {
            _ = try deserializer.deserialize(data: invalidJSON)
        }
    }

    // MARK: - Tests with keyPath parameter

    @Test("Nested single object deserializer decodes correctly with keyPath")
    func testNestedSingleObjectDeserializer() throws {
        let data = try #require(JSONStubs.nestedSinglePerson.data(using: .utf8))
        let deserializer = JSONDeserializer<TestPerson>.singleObjectDeserializer(keyPath: "response", "person")
        let person = try deserializer.deserialize(data: data)
        #expect(person == TestPerson(name: "John", age: 30))
    }

    @Test("Nested collection deserializer decodes correctly with keyPath")
    func testNestedCollectionDeserializer() throws {
        let data = try #require(JSONStubs.nestedPersonCollection.data(using: .utf8))
        let deserializer = JSONDeserializer<TestPerson>.collectionDeserializer(keyPath: "response", "persons")
        let persons = try deserializer.deserialize(data: data)
        #expect(persons == [
            TestPerson(name: "John", age: 30),
            TestPerson(name: "Jane", age: 25)
        ])
    }
}
