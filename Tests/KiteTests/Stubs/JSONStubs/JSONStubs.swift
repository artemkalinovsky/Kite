//
//  JSONStubs.swift
//  Kite
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

enum JSONStubs {
    static let singlePerson = """
        {
            "name": "John",
            "age": 30
        }
        """

    static let personCollection = """
        [
            { "name": "John", "age": 30 },
            { "name": "Jane", "age": 25 }
        ]
        """

    static let nestedSinglePerson = """
        {
            "response": {
                "person": {
                    "name": "John",
                    "age": 30
                }
            }
        }
        """

    static let nestedPersonCollection = """
        {
            "response": {
                "persons": [
                    { "name": "John", "age": 30 },
                    { "name": "Jane", "age": 25 }
                ]
            }
        }
        """
}
