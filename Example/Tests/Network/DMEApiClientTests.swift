//
//  DMEApiClientTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 29/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import OHHTTPStubs
@testable import DigiMeSDK

class DMEApiClientTests: XCTestCase {
    
    let contentBaseURL = "api.digi.me"
    
    var sut: DMEAPIClient!
    var configuration: DMEClientConfiguration!
    var scope: DMEScope!
    
    override func setUp() {
        super.setUp()
        
        scope = DMEScope()
        let timeRange = DMETimeRange.last(10, unit: DMETimeRangeUnit.day)
        scope.timeRanges = [timeRange]
        configuration = DMEPullConfiguration(appId:  "testAppId", contractId: "testContractId", p12FileName: "digimetest", p12Password: "digimetest")
        sut = DMEAPIClient(configuration: configuration!)
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
}

// MARK: - request session
extension DMEApiClientTests {

    func testGetPullSession() {
        
        let expectation = XCTestExpectation(description: "success called")
        let sessionId = "sessionId"
        stubGetPullSession(sessionIdentifier: sessionId)
        sut.requestSession(withScope: scope, success: { data in
            
            XCTAssertNotNil(data)
                if let actualContents = String(data: data, encoding: .utf8) {
                    XCTAssertEqual(actualContents, sessionId, "Expected file contents to be \(sessionId), got \(actualContents)")
                }
                else {
                    XCTFail("Could not convert contents to string")
                }
            expectation.fulfill()
            
        }) { error in
            
            XCTAssertNil(error)
        }
        
        wait(for: [expectation], timeout: 10)
    }
}

// MARK: - Stubbers
extension DMEApiClientTests {
    func stubGetPullSession(sessionIdentifier: String) {
        
        let stub1 = stub(condition: { request -> Bool in
            guard request.httpMethod == "POST",
                request.url?.host == self.contentBaseURL,
                let argHeader = request.value(forHTTPHeaderField: "Content-Type"),
                argHeader.contains("application/json"),
                let path = request.url?.path,
                path.contains("permission-access/session") else {
                    return false
            }
            
            return true
        }, response: { request in
            let stubData = sessionIdentifier.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(
                data: stubData!,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        })
        stub1.name = "Pull session id"
    }
}
