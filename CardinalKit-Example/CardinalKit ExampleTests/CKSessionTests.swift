//
//  CKSessionTests.swift
//  CardinalKit ExampleTests
//
//  Created by Vishnu Ravi on 9/10/23.
//  Copyright © 2023 CardinalKit. All rights reserved.
//

@testable import CardinalKit_Example
import CardinalKit
import XCTest

class CKSessionTests: XCTestCase {    
    // Sample keys and values for testing
    let testKey = "TestKey"
    let testValue = "TestValue"

    // Resetting Keychain
    override func setUp() {
        super.setUp()
        CKSession.removeSecure(key: testKey)
    }
    
    override func tearDown() {
        CKSession.removeSecure(key: testKey)
        super.tearDown()
    }
    
    func testGetSecureReturnsNilWhenNotSet() {
        let value = CKSession.getSecure(key: testKey)
        XCTAssertNil(value)
    }
    
    func testPutSecureSuccessfullyStoresValue() {
        CKSession.putSecure(value: testValue, forKey: testKey)
        
        let retrievedValue = CKSession.getSecure(key: testKey)
        XCTAssertEqual(retrievedValue, testValue)
    }
    
    func testPutSecureRemovesValueWhenSetToNil() {
        CKSession.putSecure(value: testValue, forKey: testKey)
        
        CKSession.putSecure(value: nil, forKey: testKey)
        
        let retrievedValue = CKSession.getSecure(key: testKey)
        XCTAssertNil(retrievedValue)
    }
    
    func testRemoveSecureRemovesValue() {
        CKSession.putSecure(value: testValue, forKey: testKey)
        
        CKSession.removeSecure(key: testKey)
        
        let retrievedValue = CKSession.getSecure(key: testKey)
        XCTAssertNil(retrievedValue)
    }
}

