//
//  JSONDeserializerTests.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 10.03.2025.
//

import Testing
import Legatus

@Suite("JSONDeserializerTests")
struct JSONDeserializerTests {
    @Test("Single object deserializer decodes correctly")
    func testSingleObjectDeserializer() async throws {
        let data = JSONStubs.singlePerson.data(using: .utf8)!
        let deserializer = JSONDeserializer<TestPerson>.singleObjectDeserializer()
        let person = try await deserializer.deserialize(data: data)
        #expect(person == TestPerson(name: "John", age: 30))
    }

    @Test("Collection deserializer decodes correctly")
    func testCollectionDeserializer() async throws {
        let data = JSONStubs.personCollection.data(using: .utf8)!
        let deserializer = JSONDeserializer<TestPerson>.collectionDeserializer()
        let persons = try await deserializer.deserialize(data: data)
        #expect(persons == [
            TestPerson(name: "John", age: 30),
            TestPerson(name: "Jane", age: 25)
        ])
    }

    @Test("Single object deserializer fails on invalid JSON")
    func testSingleObjectDeserializerFailure() async {
        let invalidJSON = "Not a JSON".data(using: .utf8)!
        let deserializer = JSONDeserializer<TestPerson>.singleObjectDeserializer()
        await #expect(throws: (any Error).self) {
            _ = try await deserializer.deserialize(data: invalidJSON)
        }
    }

    // MARK: - Tests with keyPath parameter

    @Test("Nested single object deserializer decodes correctly with keyPath")
    func testNestedSingleObjectDeserializer() async throws {
        let data = JSONStubs.nestedSinglePerson.data(using: .utf8)!
        let deserializer = JSONDeserializer<TestPerson>.singleObjectDeserializer(keyPath: "response", "person")
        let person = try await deserializer.deserialize(data: data)
        #expect(person == TestPerson(name: "John", age: 30))
    }

    @Test("Nested collection deserializer decodes correctly with keyPath")
    func testNestedCollectionDeserializer() async throws {
        let data = JSONStubs.nestedPersonCollection.data(using: .utf8)!
        let deserializer = JSONDeserializer<TestPerson>.collectionDeserializer(keyPath: "response", "persons")
        let persons = try await deserializer.deserialize(data: data)
        #expect(persons == [
            TestPerson(name: "John", age: 30),
            TestPerson(name: "Jane", age: 25)
        ])
    }
}
