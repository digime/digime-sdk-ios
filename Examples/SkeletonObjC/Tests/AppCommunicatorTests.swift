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
    
    var sut: DMEAppCommunicator!

    override func setUp() {
        sut = DMEAppCommunicator.shared()
    }
    
    func testAddingDMEAppCallback() {
        let callback = TestDMEAppCallbackHandler(testAction: testAction)
        
       sut.add(callback)
        let expectation = sut.callbackHandlers.count
        XCTAssertEqual(expectation, 1, "Expected `callbackHandlers.count` to equal 1, got \(expectation)")
    }
    
    func testRemovingDMEAppCallback() {
        let callback = TestDMEAppCallbackHandler(testAction: testAction)
        
        sut.callbackHandlers = [callback]
        
        sut.remove(callback)
        let expectation = sut.callbackHandlers.count
        XCTAssertEqual(expectation, 0, "Expected `callbackHandlers.count` to equal 0, got \(expectation)")
    }
    
    func testDigiMeBaseURL() {
        
        let digiMeBaseURL = sut.digiMeBaseURL()
        
        if let digiMeBaseURL = digiMeBaseURL {
            XCTAssert(testURL == digiMeBaseURL, "Expected `digiMeBaseURL` to equal \(testURL.absoluteString), got \(digiMeBaseURL.absoluteString)")
        } else {
            XCTFail("Expected `digiMeBaseURL` to be non-nil")
        }
    }
    
    func testCanOpenDigime() {
        
        let result = sut.canOpenDMEApp()
        let expectation = UIApplication.shared.canOpenURL(testURL)
        
        XCTAssert(result == expectation, "Expected `canOpenDMEApp` to equal \(expectation), got \(result)")
    }
    
    func testOpenActionURL() {
        let callback = TestDMEAppCallbackHandler(testAction: testAction)
        
        sut.add(callback)
        
        let result = sut.open(testActionURL, options: [:])
        XCTAssertTrue(result, "Expected `openURL` to return true, got false")
        
        XCTAssertTrue(callback.didHandleAction, "Expected `didHandleAction` to return true, got false")
    }
    
    func testOpenMismatchedActionURL() {
        let callback = TestDMEAppCallbackHandler(testAction: "mismatchedTestAction")
        
        sut.add(callback)
        
        let result = sut.open(testActionURL, options: [:])
        XCTAssertFalse(result, "Expected `openURL` to return false, got true")
        
        XCTAssertFalse(callback.didHandleAction, "Expected `didHandleAction` to return false, got true")
    }
}

class TestDMEAppCallbackHandler: NSObject, DMEAppCallbackHandler {
    
    let testAction: String
    var didHandleAction = false
    
    init(testAction: String) {
        self.testAction = testAction
        super.init()
    }
    
    func canHandleAction(_ action: String) -> Bool {
        return testAction == action
    }
    
    func handleAction(_ action: String, withParameters parameters: [String : Any]) {
        didHandleAction = testAction == action
    }
}
