//
//  XMLStubs.swift
//  Legatus
//
//  Created by Artem Kalinovsky on 11.03.2025.
//

enum XMLStubs {
    static let singlePerson = """
    <response>
      <person>
        <name>John</name>
        <age>30</age>
      </person>
    </response>
    """

    static let personCollection = """
    <response>
      <persons>
        <person>
          <name>John</name>
          <age>30</age>
        </person>
        <person>
          <name>Jane</name>
          <age>25</age>
        </person>
      </persons>
    </response>
    """
}
