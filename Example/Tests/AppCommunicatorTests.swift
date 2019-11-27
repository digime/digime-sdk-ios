//
//  AppCommunicatorTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 26/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import DigiMeSDK

class AppCommunicatorTests: XCTestCase {
    
    let testURL = URL(string: "digime-ca-master:?appName=DigiMeSDKExample")!
    let testAction = "testAction"
    var testActionURL: URL {
            return URL(string: "digime-ca-appID://\(testAction)")!
    }
    
    func testAddingDMEAppCallback() {
        let callback = TestDMEAppCallbackHandler(testAction: testAction)
        
        DMEAppCommunicator.shared().add(callback)
        let expectation = DMEAppCommunicator.shared().callbackHandlers.count
        XCTAssertEqual(expectation, 1, "Expected `callbackHandlers.count` to equal 1, got \(expectation)")
    }
    
    func testRemovingDMEAppCallback() {
        let callback = TestDMEAppCallbackHandler(testAction: testAction)
        
        DMEAppCommunicator.shared().callbackHandlers = [callback]
        
        DMEAppCommunicator.shared().remove(callback)
        let expectation = DMEAppCommunicator.shared().callbackHandlers.count
        XCTAssertEqual(expectation, 0, "Expected `callbackHandlers.count` to equal 0, got \(expectation)")
    }
    
    func testDigiMeBaseURL() {
        
        let digiMeBaseURL = DMEAppCommunicator.shared().digiMeBaseURL()
        
        if let digiMeBaseURL = digiMeBaseURL {
            XCTAssert(testURL == digiMeBaseURL, "Expected `digiMeBaseURL` to equal \(testURL.absoluteString), got \(digiMeBaseURL.absoluteString)")
        } else {
            XCTFail("Expected `digiMeBaseURL` to be non-nil")
        }
    }
    
    func testCanOpenDigime() {
        
        let result = DMEAppCommunicator.shared().canOpenDMEApp()
        let expectation = UIApplication.shared.canOpenURL(testURL)
        
        XCTAssert(result == expectation, "Expected `canOpenDMEApp` to equal \(expectation), got \(result)")
    }
    
    func testOpenActionURL() {
        let callback = TestDMEAppCallbackHandler(testAction: testAction)
        
        DMEAppCommunicator.shared().add(callback)
        
        let result = DMEAppCommunicator.shared().open(testActionURL, options: [:])
        XCTAssertTrue(result, "Expected `openURL` to return true, got false")
    }
}

class TestDMEAppCallbackHandler: NSObject, DMEAppCallbackHandler {
    
    let testAction: String
    
    init(testAction: String) {
        self.testAction = testAction
        super.init()
    }
    
    func canHandleAction(_ action: String) -> Bool {
        return testAction == action
    }
    
    func handleAction(_ action: String, withParameters parameters: [String : Any]) { }
}
