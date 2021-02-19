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
        let appId = UUID().uuidString
        let contractId = UUID().uuidString
        let privateKeyHex = UUID().uuidString
        let sut = DMEPullConfiguration(appId: appId, contractId: contractId, privateKeyHex: privateKeyHex)
        checkBaseConfigurationValues(sut: sut, appId: appId, contractId: contractId, privateKeyHex: privateKeyHex)
        
        XCTAssertNil(sut.publicKeyHex, "Expected `publicKeyHex` to be nil, got \(sut.publicKeyHex!)")
        XCTAssertTrue(sut.guestEnabled, "Expected `guestEnabled` to equal true, got false")
        XCTAssert(sut.pollInterval == 3, "Expected `pollInterval` to equal 3, got \(sut.pollInterval)")
        XCTAssert(sut.maxStalePolls == 100, "Expected `maxStalePolls` to equal 100, got \(sut.maxStalePolls)")
    }
    
    
    func testDefaultPushConfigurationValues() {
        let appId = UUID().uuidString
        let contractId = UUID().uuidString
        let privateKeyHex = UUID().uuidString
        let sut = DMEPushConfiguration(appId: appId, contractId: contractId, privateKeyHex: privateKeyHex)
        checkBaseConfigurationValues(sut: sut, appId: appId, contractId: contractId, privateKeyHex: privateKeyHex)
    }
    
    private func checkBaseConfigurationValues(sut: DMEBaseConfiguration, appId: String, contractId: String, privateKeyHex: String) {
        XCTAssert(sut.globalTimeout == 25, "Expected `globalTimeout` to equal 25, got \(sut.globalTimeout)")
        XCTAssertTrue(sut.retryOnFail, "Expected `retryOnFail` to equal true, got false")
        XCTAssert(sut.retryDelay == 750, "Expected `retryDelay` to equal 750 got \(sut.retryDelay)")
        XCTAssertTrue(sut.retryWithExponentialBackOff, "Expected `retryWithExponentialBackOff` to equal true, got false")
        XCTAssert(sut.maxRetryCount == 5, "Expected `maxRetryCount` to equal 5, got \(sut.maxRetryCount)")
        XCTAssert(sut.maxConcurrentRequests == 5, "Expected `maxConcurrentRequests` to equal 5, got \(sut.maxConcurrentRequests)")
        XCTAssertFalse(sut.debugLogEnabled, "Expected `debugLogEnabled` to equal false, got true")
        XCTAssert(sut.baseUrl == "https://api.digi.me/", "Expected `baseUrl` to equal `https://api.digi.me/`, got \(sut.baseUrl)")
        XCTAssert(sut.appId == appId, "Expected `appId` to equal `\(appId)`, got \(sut.appId)")
        XCTAssert(sut.contractId == contractId, "Expected `contractId` to equal `\(contractId)`, got \(sut.contractId)")
        XCTAssert(sut.privateKeyHex == privateKeyHex, "Expected `privateKeyHex` to equal `\(privateKeyHex)`, got \(sut.privateKeyHex)")
        XCTAssertTrue(sut.autoRecoverExpiredCredentials, "Expected `autoRecoverExpiredCredentials` to equal true, got false")
    }
}
