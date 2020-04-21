//
//  CryptographyTests.swift
//  DigiMeSDKExampleSwiftTests
//
//  Created on 19/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import XCTest

@testable import DigiMeSDK

class CryptographyTests: XCTestCase {

    var testingAssets: [AnyHashable: Any]!
    var dataDecryptor: DMEDataDecryptor!
    
    override func setUp() {
        
        guard
            let assetsPath = Bundle(for: type(of: self)).path(forResource: "CryptographyTestingAssets", ofType: "plist"),
            let assets = NSDictionary(contentsOfFile: assetsPath) as? [AnyHashable: Any],
            let privateKeyHex = assets["privateKeyHex"] as? String else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        let config = DMEPullConfiguration(appId: "testAppId", contractId: "testContractId", privateKeyHex: privateKeyHex)
        config.privateKeyHex = privateKeyHex
        dataDecryptor = DMEDataDecryptor(configuration: config)
        testingAssets = assets
    }
    
    override func tearDown() {

    }
    
    func testDataDecryptorEncrypted() {
        
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let input = assets["input"] as? String,
            let expectedResult = assets["expectedResult"] as? NSData
            else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        do {
            let output = try dataDecryptor.decryptFileContent(input) as NSData
            XCTAssert(expectedResult == output, "Failed to decrypt encrypted data.")
        }
        catch {
            XCTFail("Decrypt file content failed.")
        }
    }
    
    func testDataDecryptorUnencrypted() {
        
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let sampleDictionary = assets["testDictionary"] as? NSDictionary,
            let sampleArray = assets["testArray"] as? NSArray,
            let expectedResultDictionary = assets["expectedResultDictionary"] as? NSData,
            let expectedResultArray = assets["expectedResultArray"] as? NSData
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        do {
            let resultDictionary = try dataDecryptor.decryptFileContent(sampleDictionary) as NSData
            XCTAssert(expectedResultDictionary == resultDictionary, "Failed to process test unencrypted dictionary input data.")
            
            let resultArray = try dataDecryptor.decryptFileContent(sampleArray) as NSData
            XCTAssert(expectedResultArray == resultArray, "Failed to process test unencrypted array input data.")
        }
        catch {
            XCTFail("Decrypt file content failed.")
        }
    }
    
    func testExtractingRSAPrivateKeyHexFromBundle() {
    
        let result = DMECryptoUtilities.privateKeyHex(fromP12File: "digimetest", password: "digimetest", bundle: Bundle(for: type(of: self)))
        XCTAssertNotNil(result)
    }
    
    func testExtractingRSAPrivateKeyHexFromBytes() {
        
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let p12Data = assets["p12Data"] as? Data,
            let password = assets["p12Password"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        let result = DMECryptoUtilities.privateKeyHex(fromP12Data: p12Data, password: password)
        XCTAssertNotNil(result)
    }

    func testRandomUnsignedCharacterGeneration() {
        var map = [AnyHashable: Any]()

        for _ in 0..<10000 where map.count < 256 {
            let rand = DMECryptoUtilities.randomBytes(withLength: 1)
            map[rand] = true
        }

        XCTAssert(map.count == 256, "Failed because map count was not equal to 10000.")
    }

    func testRandomUnsignedCharacterCollision() {
        var map = [AnyHashable: Any]()

        for _ in 0..<10000 {
            let rand = DMECryptoUtilities.randomBytes(withLength: 32)
            XCTAssertNil(map[rand], "Failed because duplicate key was generated.")
            map[rand] = true
        }

        XCTAssert(map.count == 10000, "Failed because map count was not equal to 10000.")
    }
    
    func testSHA512Hashing() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let input = assets["input"] as? String,
            let data = input.data(using: .utf8) as NSData?,
            let expectedOutput = assets["expectedOutput"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        let output = (data.hashSha512() as NSData).hexString()
        XCTAssert(output == expectedOutput)
    }
    
    func testSymmetricalAESEncryption() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let expectedResults = assets["expectedResults"] as? [String],
            let key = assets["key"] as? Data,
            let iv = assets["iv"] as? Data
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        for i in 0...63 {
            var input = ""
            while input.count < i {
                input += "A"
            }

            guard let inputData = input.data(using: .utf8) else {
                return XCTFail("Failed to decode input string.")
            }

            do {
                let encryptedData = try DMECrypto.encryptAes256(usingKey: key, initializationVector: iv, data: inputData)
                let encryptedString = (encryptedData as NSData).hexString()
                let expectedEncrypted = expectedResults[i]
                XCTAssert(encryptedString == expectedEncrypted, "Failed becasuse encrypted output does not match the expected output.")

                let decryptedData = try DMECrypto.decryptAes256(usingKey: key, initializationVector: iv, data: encryptedData)
                let decryptedString = String(data: decryptedData, encoding: .utf8)
                XCTAssert(decryptedString == input, "Failed becasuse decrypted output does not match the original input.")
            }
            catch {
                XCTFail("AES encryption/decryption failed.")
            }
        }
    }

    func testRSA2048Encryption() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let publicKeyHex = assets["publicKeyHex"] as? String,
            let privateKeyHex = assets["privateKeyHex"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        let publicKeyData = publicKeyHex.hexToBytes() as NSData
        let privateKeyData = privateKeyHex.hexToBytes() as NSData

        guard
            let publicKey = SecKeyCreateWithData(publicKeyData as CFData, [kSecAttrKeyType: kSecAttrKeyTypeRSA, kSecAttrKeyClass: kSecAttrKeyClassPublic] as CFDictionary, nil),
            let privateKey = SecKeyCreateWithData(privateKeyData as CFData, [kSecAttrKeyType: kSecAttrKeyTypeRSA, kSecAttrKeyClass: kSecAttrKeyClassPrivate] as CFDictionary, nil)
            else {
                return XCTFail("Failed to create SecKey objects from binary key representations.")
        }

        // Let's run the test a good few times.
        for _ in 0..<64 {
            let input = DMECryptoUtilities.randomBytes(withLength: 120)

            do {
                let encrypted = DMECrypto.encryptLargeData(input, publicKey: publicKey)
                let decrypted = DMECrypto.decryptLargeData(encrypted, privateKey: privateKey)

                XCTAssert(input == decrypted, "Failed because the RSA2048 encrypted and subsequently decrypted string doesn't match the original input.")
            }
        }
    }
}

