//
//  RouterTests.swift
//  DigiMeSDKExample
//
//  Created on 07/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

@testable import DigiMeSDK
import Foundation
import XCTest

class RouterTests: XCTestCase {
    var options: ReadOptions!
    
    override func setUp() {
        super.setUp()
        
        let timeRange = TimeRange.last(amount: 10, unit: .day)
        let scope = Scope(timeRanges: [timeRange])
        options = ReadOptions(limits: nil, scope: scope)
    }
    
    override func tearDown() {
        options = nil
        super.tearDown()
    }
    
    func testAuthorizeRequest() throws {
        let jwt = UUID().uuidString
        let sut = AuthorizeRoute(jwt: jwt, readOptions: options)
		let request = sut.toUrlRequest(with: "path")
        
        XCTAssert(request.httpMethod == "POST", "Error testing Authorize request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Authorize request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("oauth/authorize"), "Error testing Authorize request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Authorize request. Headers are nil.")
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers[HeaderKey.authorization], "Bearer \(jwt)")
        XCTAssertEqual(headers[HeaderKey.contentType], "application/json")
        
        XCTAssertNil(request.httpBodyStream)
        
        guard
            let postData = request.httpBody,
            let json = try? JSONSerialization.jsonObject(with: postData, options: []),
            let dictionary = json as? [String: AnyHashable] else {
                XCTFail("Error testing Authorize request. Authorize post data is missing")
                return
        }
        
        XCTAssertNotNil(dictionary[BodyKey.agent])
        
        guard
            let actions = dictionary[BodyKey.actions] as? [String: AnyHashable],
            let pull = actions[BodyKey.pull] as? [String: AnyHashable] else {
            XCTFail("Error testing Authorize request. Read options post data is missing")
            return
        }
        
        XCTAssertNotNil(pull[BodyKey.accept] as? [String: String])
        XCTAssertNotNil(pull[BodyKey.scope] as? [String: AnyHashable])
        XCTAssertNil(pull[BodyKey.limits])
    }
    
    func testTokenExchangeRequest() throws {
        let jwt = UUID().uuidString
        let sut = TokenExchangeRoute(jwt: jwt)
		let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "POST", "Error testing Token Exchange request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Token Exchange request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("oauth/token"), "Error testing Token Exchange request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Token Exchange request. Headers are nil.")
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.authorization], "Bearer \(jwt)")
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testFileListRequest() throws {
		let jwt = UUID().uuidString
        let sessionKey = UUID().uuidString
		let sut = FileListRoute(jwt: jwt, sessionKey: sessionKey)
		let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "GET", "Error testing File List request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing File List request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("permission-access/query"), "Error testing File List request. Endpoint is incorrect.")
        XCTAssertTrue(url.absoluteString.contains(sessionKey), "Error testing File List request. Session key is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing File List request. Headers are nil.")
        XCTAssertTrue(headers.isEmpty)
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testFileRequest() throws {
		let jwt = UUID().uuidString
        let fileId = "testFileId"
        let sessionKey = UUID().uuidString
		let sut = ReadDataRoute(jwt: jwt, sessionKey: sessionKey, fileId: fileId)
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "GET", "Error testing File request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing File request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("permission-access/query"), "Error testing File request. Endpoint is incorrect.")
        XCTAssertTrue(url.absoluteString.contains(sessionKey), "Error testing File request. Session key is incorrect.")
        XCTAssertTrue(url.absoluteString.contains(fileId), "Error testing File request. File id is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing File request. Headers are nil.")
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.accept], "application/octet-stream")
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testTriggerRequest() throws {
        let jwt = UUID().uuidString
        let sut = TriggerSyncRoute(jwt: jwt, readOptions: options)
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "POST", "Error testing Trigger request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Trigger request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("permission-access/trigger"), "Error testing Trigger request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Trigger request. Headers are nil.")
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers[HeaderKey.authorization], "Bearer \(jwt)")
        XCTAssertEqual(headers[HeaderKey.contentType], "application/json")
        
        XCTAssertNil(request.httpBodyStream)
        
        guard
            let postData = request.httpBody,
            let json = try? JSONSerialization.jsonObject(with: postData, options: []),
            let dictionary = json as? [String: AnyHashable] else {
                XCTFail("Error testing Authorize request. Trigger post data is missing")
                return
        }
        
        XCTAssertNotNil(dictionary[BodyKey.agent])
        XCTAssertNotNil(dictionary[BodyKey.accept] as? [String: String])
        XCTAssertNotNil(dictionary[BodyKey.scope] as? [String: AnyHashable])
        XCTAssertNil(dictionary[BodyKey.limits])
    }
    
    func testWriteRequest() throws {
        let postboxId = "testPostboxId"
        let payload = Data()
        let jwt = UUID().uuidString
        let sut = WriteDataRoute(postboxId: postboxId, payload: payload, jwt: jwt)
        let request = sut.toUrlRequest(with: "path")

        XCTAssertEqual(request.httpMethod, "POST", "Error testing Write request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Write request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("permission-access/postbox"), "Error testing Write request. Endpoint is incorrect.")
        XCTAssertTrue(url.absoluteString.contains(postboxId), "Error testing Write request. Postbox id is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Write request. Headers are nil.")
        XCTAssertEqual(headers.count, 4)
        XCTAssertEqual(headers[HeaderKey.authorization], "Bearer \(jwt)")
        try XCTAssertTrue(XCTUnwrap(headers[HeaderKey.contentType]).contains("multipart/form-data; boundary="))
        XCTAssertEqual(headers[HeaderKey.accept], "application/json")
        XCTAssertNotNil(headers[HeaderKey.contentLength])
        
        guard
            let postData = request.httpBody,
            let bodyString = String.init(bytes: postData, encoding: .utf8) else {
                XCTFail("Error testing Write request. Postbox request http body data is missing.")
                return
        }
        XCTAssertTrue(bodyString.contains("--Boundary-"), "Error testing Write request. Boundary is missing.")
        XCTAssertTrue(bodyString.contains("Content-Disposition: form-data; name=\"file\"; filename=\"file\""), "Error testing Write request. Content disposition is missing.")
    }
    
    func testDeleteUserRoute() throws {
        let jwt = UUID().uuidString
        let sut = DeleteUserRoute(jwt: jwt)
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "DELETE", "Error testing Delete User request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Delete User request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("user"), "Error testing Delete User request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Delete User request. Headers are nil.")
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.authorization], "Bearer \(jwt)")
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testServicesRoute() throws {
        let sut = ServicesRoute(contractId: nil)
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "GET", "Error testing Services request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Services request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("discovery/services"), "Error testing Services request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Services request. Headers are nil.")
        XCTAssertTrue(headers.isEmpty)
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testServicesRouteWithContractId() throws {
        let contractId = UUID().uuidString
        let sut = ServicesRoute(contractId: contractId)
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "GET", "Error testing Services request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Services request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("discovery/services"), "Error testing Services request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Services request. Headers are nil.")
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.contractId], contractId)
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testTokenReferenceRoute() throws {
        let jwt = UUID().uuidString
        let sut = TokenReferenceRoute(jwt: jwt)
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "POST", "Error testing Token Reference request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing Token Reference request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("oauth/token/reference"), "Error testing Token Reference request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing Token Reference request. Headers are nil.")
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.authorization], "Bearer \(jwt)")
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    func testWebKeySetRoute() throws {
        let sut = WebKeySetRoute()
        let request = sut.toUrlRequest(with: "path")
        
        XCTAssertEqual(request.httpMethod, "GET", "Error testing JWKS request. Http method is incorrect.")
        
        let url = try XCTUnwrap(request.url, "Error testing JWKS request. Url is empty.")
        XCTAssertTrue(url.absoluteString.contains("jwks/oauth"), "Error testing JWKS request. Endpoint is incorrect.")
        XCTAssertNil(url.query)
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields, "Error testing JWKS request. Headers are nil.")
        XCTAssertTrue(headers.isEmpty)
        
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.httpBodyStream)
    }
    
    private enum HeaderKey {
        static let accept = "Accept"
        static let authorization = "Authorization"
        static let contentLength = "Content-Length"
        static let contentType = "Content-Type"
        static let contractId = "contractId"
    }
    
    private enum BodyKey {
        static let accept = "accept"
        static let actions = "actions"
        static let agent = "agent"
        static let limits = "limits"
        static let pull = "pull"
        static let scope = "scope"
    }
}
