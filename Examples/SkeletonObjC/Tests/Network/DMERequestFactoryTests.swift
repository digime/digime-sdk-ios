//
//  DMERequestFactoryTests.swift
//  DigiMeSDKExample
//
//  Created on 20/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

@testable import DigiMeSDK
import Foundation
import XCTest

class DMERequestFactoryTests: XCTestCase {
    var sut: DMERequestFactory!
    var options: DMESessionOptions!
    var testAppId: String!
    var testContractId: String!
    var sessionKey: String!
    
    override func setUp() {
        super.setUp()
        
        testAppId = "testAppId"
        testContractId = "testContractId"
        sessionKey = "testSessionKey"
        
        options = DMESessionOptions()
        let scope = DMEScope()
        let timeRange = DMETimeRange.last(10, unit: DMETimeRangeUnit.day)
        options.scope = scope
        options.scope!.timeRanges = [timeRange]
        
        let configuration = DMEPullConfiguration(appId: testAppId, contractId: testContractId, p12FileName: "digimetest", p12Password: "digimetest")
        sut = DMERequestFactory(configuration: configuration!)
    }
    
    override func tearDown() {
        sut = nil
        options = nil
        super.tearDown()
    }
    
    func testSessionRequest() {
        let request = sut.sessionRequest(withAppId: testAppId, contractId: testContractId, options: options)
        XCTAssert(request.httpMethod == "POST", "Error testing session request. Http method is incorrect.")
        XCTAssert(request.httpBody != nil, "Error testing session request. Body is empty.")
        XCTAssert(request.url != nil, "Error testing session request. Url is empty.")
        XCTAssert(request.url?.absoluteString.hasSuffix("permission-access/session") == true, "Error testing session request. Argon endpoint is incorrect.")
        
        guard
            let postData = request.httpBody,
            let postKeysDict = try? JSONSerialization.jsonObject(with: postData, options: []),
            let postKeys = postKeysDict as? [String: AnyHashable] else {
                XCTFail("Error testing session request. Session request post data is missing")
                return
        }
        
        XCTAssert(postKeys[Keys.appId] as? String == testAppId, "Error testing session request. AppId is incorrect.")
        XCTAssert(postKeys[Keys.contractId] as? String == testContractId, "Error testing session request. ContractId is incorrect.")
        XCTAssert(postKeys[Keys.sdkAgent] != nil, "Error testing session request. SdkAgent is nil.")
        
        let accept = postKeys[Keys.accept] as? [String: String]
        XCTAssert(accept != nil, "Error testing session request. Post key accept is missing.")
        XCTAssert(accept?[Keys.compression] == "gzip", "Error testing session request.")
        XCTAssert(postKeys[options.scope!.context] as? [AnyHashable: Any] != nil, "Error testing session request.")
    }
    
    func testFileListRequest() {
        let request = sut.fileListRequest(withSessionKey: sessionKey)
        XCTAssert(request.httpMethod == "GET", "Error testing File List request. Http method is incorrect.")
        XCTAssert(request.url != nil, "Error testing File List request. Url is empty.")
        XCTAssert(request.url?.absoluteString.contains("permission-access/query") == true, "Error testing File List request. Argon endpoint is incorrect.")
        XCTAssert(request.url?.absoluteString.contains(sessionKey) == true, "Error testing File List request. Session key is incorrect.")
    }
    
    func testFileRequest() {
        let fileId = "testFileId"
        let request = sut.fileRequest(withId: fileId, sessionKey: sessionKey)
        XCTAssert(request.httpMethod == "GET", "Error testing File request. Http method is incorrect.")
        XCTAssert(request.url != nil, "Error testing File request. Url is empty.")
        XCTAssert(request.url?.absoluteString.contains("permission-access/query") == true, "Error testing File request. Argon endpoint is incorrect.")
        XCTAssert(request.url?.absoluteString.contains(fileId) == true, "Error testing File request. File id is incorrect.")
    }
    
    func testPushRequest() {
        let postboxId = "testPostboxId"
        let bearer = UUID().uuidString
        
        let payload = Data()
        let request = sut.pushRequest(withPostboxId: postboxId, payload: payload, bearer: bearer)
        
        XCTAssert(request.httpMethod == "POST", "Error testing postbox push request. Http method is incorrect.")
        XCTAssert(request.httpBody != nil, "Error testing postbox push request. Body is empty.")
        XCTAssert(request.url != nil, "Error testing postbox push request. Url is empty.")
        XCTAssert(request.url?.absoluteString.contains("permission-access/postbox") == true, "Error testing postbox push request. Argon endpoint is incorrect.")
        XCTAssert(request.url?.absoluteString.contains(postboxId) == true, "Error testing postbox push request. Postbox id is incorrect.")
        
        guard
            let postData = request.httpBody,
            let bodyString = String.init(bytes: postData, encoding: .utf8) else {
                XCTFail("Error testing postbox push request. Postbox request http body data is missing.")
                return
        }
        XCTAssert(bodyString.contains("Boundary") == true, "Error testing postbox push request. Boundary is missing.")
        XCTAssert(bodyString.contains("Content-Type: multipart/form-data") == true, "Error testing postbox push request. Content type is missing.")
        XCTAssert(bodyString.contains("filename=file") == true, "Error testing postbox push request. File data is missing.")
        
        guard let headerFields = request.allHTTPHeaderFields else {
            XCTFail("Error testing postbox push request. Session request header params are missing.")
            return
        }
        
        XCTAssert(headerFields[Keys.contentType] != nil, "Error testing postbox push request. Content type param is missing.")
        XCTAssert(headerFields[Keys.acceptPostbox] != nil, "Error testing postbox push request. Accept header param is missing.")
        XCTAssert(headerFields[Keys.authorization] == "Bearer \(bearer)", "Error testing postbox push request. Authorization header is either missing or incorrect.")
    }
    
    private struct Keys {
        static let appId = "appId"
        static let contractId = "contractId"
        static let sdkAgent = "sdkAgent"
        static let accept = "accept"
        static let compression = "compression"
        static let contentType = "Content-Type"
        static let acceptPostbox = "Accept"
        static let sessionKey = "sessionKey"
        static let symmetricalKey = "symmetricalKey"
        static let iv = "iv"
        static let metadata = "metadata"
        static let authorization = "Authorization"
    }
}
