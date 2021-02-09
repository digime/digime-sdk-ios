//
//  CertificatePinningTests.swift
//  DigiMeSDKExampleTests
//
//  Created on 21/05/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import XCTest
@testable import DigiMeSDK

class CertificatePinningTests: XCTestCase {
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    // Tests don't work in Debug as certificate pinner will always return "default handling"
    func xtestCertificatePinningTestsPositive() {
        let expectation = XCTestExpectation(description: "Connection to digi.me endpoints should succeed if certificates match")
        let baseUrl = URL(string: "https://api.digi.me")!
        
        let certPinningConnection = CertificatePinningConnection(url: baseUrl) { disposition in
            XCTAssert(disposition == URLSession.AuthChallengeDisposition.useCredential, "Request challenge disposition doesn't match the expectation")
            expectation.fulfill()
        }

        certPinningConnection.connect()
        
        wait(for: [expectation], timeout: 2)
    }
    
    // Tests don't work in Debug as certificate pinner will always return "default handling"
    func xtestCertificatePinningTestsNegative() {
        let expectation = XCTestExpectation(description: "When using fake FQDN it should fail")
        let baseUrl = URL(string: "https://www.google.com/")!
        let certPinningConnection = CertificatePinningConnection(url: baseUrl) { disposition in
            XCTAssert(disposition == URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, "Request challenge disposition doesn't match the expectation")
            expectation.fulfill()
        }

        certPinningConnection.connect()
        
        wait(for: [expectation], timeout: 2)
    }
}

class CertificatePinningConnection: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    var pinningEvaluation: ((URLSession.AuthChallengeDisposition) -> Void)?
    private(set) var url: URL

    init(url: URL, completion: @escaping (URLSession.AuthChallengeDisposition) -> Void) {
        self.url = url
        super.init()
        pinningEvaluation = completion
    }

    func connect() {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let pinningEvaluation = pinningEvaluation {
            pinningEvaluation(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge)
        }

        pinningEvaluation = nil
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("Did receive response")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let pinningEvaluation = pinningEvaluation {
            let disposition = DMECertificatePinner().authenticateURLChallenge(challenge)
            pinningEvaluation(disposition)
        }

        pinningEvaluation = nil
        task.cancel()
    }
}

