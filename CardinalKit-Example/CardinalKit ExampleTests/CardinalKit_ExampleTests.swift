//
//  CardinalKit_ExampleTests.swift
//  CardinalKit ExampleTests
//
//  Created by Vishnu Ravi on 12/24/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

@testable import CardinalKit_Example
import XCTest

// swiftlint:disable type_name
final class CardinalKit_ExampleTests: XCTestCase {
    func testReadConfig() {
        let config = CKPropertyReader(file: "CKConfiguration")
        XCTAssertNotNil(config.data)
    }
}
