//
//  ErrorTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 30/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

class ErrorTests: XCTestCase {
    
    var errorReference: String!
    var errorMessage: String!
    
    override func setUp() {
        super.setUp()
        
        errorReference = "wZqzGZtxpyMF9yImziPYXI5u7pE5ZlkB"
        errorMessage = "Produced error object does not match expectation"
    }

    override func tearDown() {
        errorReference = nil
        errorMessage = nil
        
        super.tearDown()
    }
    
    func testAuthErrorGeneral() {
        let error = NSError.authError(AuthError.general, reference: errorReference)
        let localizedDescription = error.localizedDescription
        XCTAssert(localizedDescription.contains(errorReference), "\(#function) " + errorMessage)
    }
}
