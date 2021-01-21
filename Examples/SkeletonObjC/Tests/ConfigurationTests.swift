//
//  ConfigurationTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 12/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit
import XCTest
@testable import DigiMeSDK

class ConfigurationTests: XCTestCase {
    
    func testDefaultPullConfigurationValues() {
        let sut = DMEPullConfiguration(appId: "appid1", contractId: "contractid1", privateKeyHex: "keyhex1")
        
        XCTAssert(sut.globalTimeout == 25, "Expected `globalTimeout` to equal 25, got \(sut.globalTimeout)")
        XCTAssertTrue(sut.retryOnFail, "Expected `retryOnFail` to equal true, got false")
        XCTAssert(sut.retryDelay == 750, "Expected `retryDelay` to equal 755, got \(sut.retryDelay)")
        XCTAssertTrue(sut.retryWithExponentialBackOff, "Expected `retryWithExponentialBackOff` to equal true, got false")
        XCTAssert(sut.maxRetryCount == 5, "Expected `maxRetryCount` to equal 5, got \(sut.maxRetryCount)")
        XCTAssert(sut.maxConcurrentRequests == 5, "Expected `maxConcurrentRequests` to equal 5, got \(sut.maxConcurrentRequests)")
        XCTAssertFalse(sut.debugLogEnabled, "Expected `debugLogEnabled` to equal false, got true")
        XCTAssert(sut.baseUrl == "https://api.digi.me/", "Expected `baseUrl` to equal `https://api.digi.me/`, got \(sut.baseUrl)")
        XCTAssert(sut.appId == "appid1", "Expected `appId` to equal `appid1`, got \(sut.appId)")
        XCTAssert(sut.contractId == "contractid1", "Expected `contractId` to equal `contractid1`, got \(sut.contractId)")
        XCTAssertTrue(sut.guestEnabled, "Expected `guestEnabled` to equal true, got false")
        XCTAssert(sut.privateKeyHex == "keyhex1", "Expected `privateKeyHex` to equal `keyhex1`, got \(sut.privateKeyHex)")
    }
    
    
    func testDefaultPushConfigurationValues() {
        let sut = DMEPushConfiguration(appId: "appid1", contractId: "contractid1")
        
        XCTAssert(sut.globalTimeout == 25, "Expected `globalTimeout` to equal 25, got \(sut.globalTimeout)")
        XCTAssertTrue(sut.retryOnFail, "Expected `retryOnFail` to equal true, got false")
        XCTAssert(sut.retryDelay == 750, "Expected `retryDelay` to equal 755, got \(sut.retryDelay)")
        XCTAssertTrue(sut.retryWithExponentialBackOff, "Expected `retryWithExponentialBackOff` to equal true, got false")
        XCTAssert(sut.maxRetryCount == 5, "Expected `maxRetryCount` to equal 5, got \(sut.maxRetryCount)")
        XCTAssert(sut.maxConcurrentRequests == 5, "Expected `maxConcurrentRequests` to equal 5, got \(sut.maxConcurrentRequests)")
        XCTAssertFalse(sut.debugLogEnabled, "Expected `debugLogEnabled` to equal false, got true")
        XCTAssert(sut.baseUrl == "https://api.digi.me/", "Expected `baseUrl` to equal `https://api.digi.me/`, got \(sut.baseUrl)")
        XCTAssert(sut.appId == "appid1", "Expected `appId` to equal `appid1`, got \(sut.appId)")
        XCTAssert(sut.contractId == "contractid1", "Expected `contractId` to equal `contractid1`, got \(sut.contractId)")
    }
}
