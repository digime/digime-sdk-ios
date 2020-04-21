//
//  DMELoggerTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 23/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

class DMELoggerTests: XCTestCase {

    func testSDKDeprecationStatus() {
        let headerFields = ["x-digi-sdk-status": "sdkStatus", "x-digi-sdk-status-message": "sdkMessage"]
        
        let expectedMessage = "\n===========================================================\nSDK Status: sdkStatus\nsdkMessage\n==========================================================="
        
        XCTAssertEqual(DMEStatusLogger.getSDKStatus(headerFields),expectedMessage)
    }
}
