//
//  CyclicCATests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 02/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
import CryptorRSA
import Foundation
import SwiftJWT
import XCTest

class CyclicCATests: XCTestCase {
    struct Keys {
        static let token = "jwtToken"
        static let title = "title"
        static let valid = "valid"
    }
    
    struct TestClaimsVerification: Claims {
        let test: String
    }
    
    struct TestClaimsDecoding: Claims {
        let preauthorization_code: String
    }
    
    var header: Header!
    var publicKey: Data!
    var privateKey: Data!
    var testingAssets: [AnyHashable: Any]!
    
    override func setUp() {
        guard
            let assetsPath = Bundle(for: type(of: self)).path(forResource: "CyclicCATestingAssets", ofType: "plist"),
            let assets = NSDictionary(contentsOfFile: assetsPath) as? [AnyHashable: Any],
            let publicKeyBase64 = assets["publicKey"] as? String,
            let privateKeyBase64 = assets["privateKey"] as? String,
            let publicKeyData = convertKeyString(publicKeyBase64),
            let privateKeyData = convertKeyString(privateKeyBase64) else {
                XCTFail("Failed to load required testing assets.")
                return
        }
        
        publicKey = publicKeyData
        privateKey = privateKeyData
        header = Header(typ: "JWT",
                        jku: "https://api.development.devdigi.me/v1/jwks/oauth",
                        jwk: nil,
                        kid: "https://digime-alpha-key-vault.vault.azure.net/keys/jfs-signing/a46b49e1fd66470d9ef7d444b5429243",
                        x5u: nil,
                        x5c: nil,
                        x5t: nil,
                        x5tS256: nil,
                        cty: nil,
                        crit: nil)
        testingAssets = assets
    }
    
    override func tearDown() {
        publicKey = nil
        privateKey = nil
        header = nil
    }
    
    func testSigningAndVerifyingJWT() {
        let claims = TestClaimsVerification(test: "value1")
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKey)
        guard let signedToken = try? jwt.sign(using: signer) else {
            XCTFail("Error signing our test token")
            return
        }

        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<TestClaimsVerification>.verify(signedToken, using: verifier)
        XCTAssert(isVerified, "Signing test has failed")
    }
    
    func testVerifyJWT() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let testsAssets = assets["testsAssets"] as? [[String: Any]] else {
                return XCTFail("Failed to load required testing assets.")
        }

        testsAssets.forEach { (testCase) in
            guard
                let signedToken = testCase[Keys.token] as? String,
                let title = testCase[Keys.title] as? String,
                let expectation = testCase[Keys.valid] as? Bool else {
                    XCTFail("Error loading test data")
                    return
            }
            
            let verifier = JWTVerifier.ps512(publicKey: publicKey)
            let isVerified = JWT<TestClaimsVerification>.verify(signedToken, using: verifier)
            XCTAssert(isVerified == expectation, title)
        }
    }
    
    func testDecodeJWTPayload() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let sampleJWT = assets["sampleJWT"] as? String,
            let resultJWT = try? JWT<TestClaimsDecoding>(jwtString: sampleJWT) else {
                return XCTFail("Failed to load required testing assets.")
        }

        let expectedClaims = TestClaimsDecoding(preauthorization_code: "sst")
        let resultClaims = resultJWT.claims
        XCTAssert(expectedClaims.preauthorization_code == resultClaims.preauthorization_code, "Decoding and comparing claims has failed")
    }
    
    // MARK: - Private utility functions
    private func convertKeyString(_ keyString: String) -> Data? {
        guard let base64String = try? CryptorRSA.base64String(for: keyString) else {
            XCTFail("Couldn't read a key string")
            return nil
        }
        
        return convertKeyBase64ToData(base64String)
    }
    
    private func convertKeyBase64ToData(_ base64KeyString: String) -> Data? {
        guard let publicKeyData = Data(base64Encoded: base64KeyString, options: [.ignoreUnknownCharacters]) else {
            XCTFail("Couldn't decode base64 key")
            return nil
        }
        
        return publicKeyData
    }
}
