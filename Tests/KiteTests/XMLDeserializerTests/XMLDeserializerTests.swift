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

    @Test("Default initializer decodes root XML object")
    func testDefaultInitializerDecodesRootObject() throws {
        let rootPersonXML = """
        <person>
          <name>John</name>
          <age>30</age>
        </person>
        """
        let data = try #require(rootPersonXML.data(using: .utf8))
        let deserializer = XMLDeserializer<TestPerson>()
        let person = try deserializer.deserialize(data: data)

        #expect(person == TestPerson(name: "John", age: 30))
    }

    @Test("Default initializer returns XMLIndexer")
    func testDefaultInitializerReturnsXMLIndexer() throws {
        let data = try #require(XMLStubs.singlePerson.data(using: .utf8))
        let deserializer = XMLDeserializer<XMLIndexer>()
        let xml = try deserializer.deserialize(data: data)
        let name: String = try xml["response"]["person"]["name"].value()

        #expect(name == "John")
    }

    @Test("Default initializer decodes root XML object with XML prolog")
    func testDefaultInitializerDecodesRootObjectWithXMLProlog() throws {
        let rootPersonXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <person>
          <name>John</name>
          <age>30</age>
        </person>
        """
        let data = try #require(rootPersonXML.data(using: .utf8))
        let deserializer = XMLDeserializer<TestPerson>()
        let person = try deserializer.deserialize(data: data)

        #expect(person == TestPerson(name: "John", age: 30))
    }

    @Test("Default initializer throws specific error when XML has no element nodes")
    func testDefaultInitializerFailsWhenXMLContainsNoElements() throws {
        let xmlWithNoElements = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!-- empty -->
        """
        let data = try #require(xmlWithNoElements.data(using: .utf8))
        let deserializer = XMLDeserializer<TestPerson>()
        do {
            _ = try deserializer.deserialize(data: data)
            Issue.record("Expected XMLDeserializerError.xmlDeserializationFailed for XML without element nodes.")
        } catch let error as XMLDeserializerError {
            #expect(error.errorDescription == "XML document contains no element nodes.")
        } catch {
            Issue.record("Unexpected error type: \(type(of: error))")
        }
    }
}
