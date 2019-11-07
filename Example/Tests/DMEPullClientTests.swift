//
//  DMEPullClientTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 04/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import DigiMeSDK

class DMEPullClientTests: XCTestCase {

    let contentBaseURL = "api.digi.me"
    
    override func setUp() {
        
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testPullSessionCancellation() {
        let expectation = XCTestExpectation(description: "Session fetch has been cancelled.")
        
        let sessionId = UUID().uuidString
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "FileListResponseStaticRunning", ofType: "json")
        let response = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        stubPullSession(sessionIdentifier: sessionId)
        stubFileList(sessionIdentifier: sessionId, response: response)
        stubFileResponse404(sessionIdentifier: sessionId, fileIdentifier: "testFile_1.json")
        stubFileResponse404(sessionIdentifier: sessionId, fileIdentifier: "testFile_2.json")
        stubFileResponse404(sessionIdentifier: sessionId, fileIdentifier: "testFile_3.json")
        stubFileResponse404(sessionIdentifier: sessionId, fileIdentifier: "testFile_4.json")
        
        let configuration = DMEPullConfiguration(appId: "test_app", contractId: "test_contract", privateKeyHex: "test_key_hex")
        configuration.maxConcurrentRequests = 1
        
        //force fast retries so that operations can pickup cancellations quickly for the purposes of the test
        configuration.maxRetryCount = 300 //total 3 seconds
        configuration.retryDelay = 10 // retry every hundredth of a second
        
        let sut = DMEPullClient(configuration: configuration)
        
        sut.sessionManager.session(withScope: nil) { session, error in
            sut.getSessionData(downloadHandler: { file, error in
                XCTFail("File download was not expected to complete. Session fetching should have been cancelled.")
            }) { error in
                XCTFail("session fetching should have been cancelled, and was not expected to call completion.")
            }
        
            //arbitrary delay to ensure that file downloads are attempted.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sut.cancel()
                
                //allow for cancel command to propagate down the chain.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    XCTAssertTrue(sut.apiClient.queue.operationCount == 0, "Expected there to be 0 operations, but there are \(sut.apiClient.queue.operationCount)")
                    XCTAssertFalse(sut.fetchingSessionData, "Data fetching should have been cancelled, but it is still running.")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.5)
    }
    
}

// MARK: - Stubbers
extension DMEPullClientTests {
    func stubPullSession(sessionIdentifier: String) {
        
        let sessionResponse: [String: Any] = [
            "expiry": (Date().timeIntervalSince1970 + 500) * 1000, //milliseconds - 500 is random seconds into the future
            "sessionKey": sessionIdentifier,
            "sessionExchangeToken": "session_exchange_token"
        ]

        guard let sessionData = try? JSONSerialization.data(withJSONObject: sessionResponse, options: .prettyPrinted) else {
            XCTFail("Couldn't serialize session response")
            return
        }
        
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
            return OHHTTPStubsResponse(
                data: sessionData,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        })
        stub1.name = "get session id"
    }
    
    func stubFileList(sessionIdentifier:String, response: Data) {
        let fileListStub = stub(condition: { request -> Bool in
            guard request.httpMethod == "GET",
                request.url?.host == self.contentBaseURL,
                let argHeader = request.value(forHTTPHeaderField: "Content-Type"),
                argHeader.contains("application/json"),
                let path = request.url?.path,
                path.contains("permission-access/query/\(sessionIdentifier)") else {
                    return false
            }
            
            return true
        }, response: { request in
            return OHHTTPStubsResponse(
                data: response,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        })
        fileListStub.name = "get file list"
    }
    
    func stubFileResponse404(sessionIdentifier: String, fileIdentifier: String) {
        let data = try! JSONSerialization.data(withJSONObject: [], options: .prettyPrinted)
        
        let fileResponseStub = stub(condition: { request -> Bool in
            guard request.httpMethod == "GET",
                request.url?.host == self.contentBaseURL,
                let argHeader = request.value(forHTTPHeaderField: "Content-Type"),
                argHeader.contains("application/json"),
                let path = request.url?.path,
                path.contains("permission-access/query/\(sessionIdentifier)/\(fileIdentifier)") else {
                    return false
            }
            
            return true
        }, response: { request in
            return OHHTTPStubsResponse(
                data: data,
                statusCode: 404,
                headers: ["Content-Type": "application/json"]
            )
        })
        fileResponseStub.name = "get file stub (404)"
    }
}

