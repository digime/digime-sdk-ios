//
//  DMEErrorTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 23/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

class DMEErrorTests: XCTestCase {

    func testSDKError() {
        XCTAssertEqual("me.digi.sdk", SDK_ERROR)
    }
    
    func testSDKApiError() {
        XCTAssertEqual("me.digi.sdk.api", DME_API_ERROR)
    }
    
    func testSDKAuthorizationError() {
        XCTAssertEqual("me.digi.sdk.authorization", DME_AUTHORIZATION_ERROR)
    }
}
