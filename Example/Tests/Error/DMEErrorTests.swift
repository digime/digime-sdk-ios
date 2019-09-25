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
        let error = NSError.sdkError(.noAppId) as NSError
        XCTAssertEqual("me.digi.sdk", error.domain)
    }
    
    func testSDKAuthorizationError() {
        let error = NSError.authError(.general) as NSError
        XCTAssertEqual("me.digi.sdk.authorization", error.domain)
    }
    
    func testSDKApiError() {
        XCTAssertEqual("me.digi.sdk.api", DME_API_ERROR)
    }
}
