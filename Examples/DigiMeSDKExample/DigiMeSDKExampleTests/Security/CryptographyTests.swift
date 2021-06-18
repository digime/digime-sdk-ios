//
//  CryptographyTests.swift
//  DigiMeSDKExampleTests
//
//  Created on 19/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import CryptoKit
import XCTest

@testable import DigiMeSDK

class CryptographyTests: XCTestCase {

    var testingAssets: [AnyHashable: Any]!
    
    override func setUp() {
        
        guard
            let assetsPath = Bundle(for: type(of: self)).path(forResource: "CryptographyTestingAssets", ofType: "plist"),
            let assets = NSDictionary(contentsOfFile: assetsPath) as? [AnyHashable: Any] else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        testingAssets = assets
    }
    
    func testDataDecryptorEncrypted() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let input = assets["input"] as? String,
            let expectedResult = assets["expectedResult"] as? Data,
            let dataDecryptor = setupDataDecryptor()
            else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        do {
            let output = try dataDecryptor.decrypt(fileContent: input)
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
            let expectedResultDictionary = assets["expectedResultDictionary"] as? Data,
            let expectedResultArray = assets["expectedResultArray"] as? Data,
            let dataDecryptor = setupDataDecryptor()
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        do {
            let resultDictionary = try dataDecryptor.decrypt(fileContent: sampleDictionary)
            XCTAssert(expectedResultDictionary == resultDictionary, "Failed to process test unencrypted dictionary input data.")
            
            let resultArray = try dataDecryptor.decrypt(fileContent: sampleArray)
            XCTAssert(expectedResultArray == resultArray, "Failed to process test unencrypted array input data.")
        }
        catch {
            XCTFail("Decrypt file content failed.")
        }
    }
    
    func testRandomUnsignedCharacterGeneration() {
        var map = [AnyHashable: Any]()

        for _ in 0..<10000 where map.count < 256 {
            let rand = Crypto.secureRandomBytes(length: 1)
            map[rand] = true
        }

        XCTAssert(map.count == 256, "Failed because map count was not equal to 10000.")
    }

    func testRandomUnsignedCharacterCollision() {
        var map = [AnyHashable: Any]()

        for _ in 0..<10000 {
            let rand = Crypto.secureRandomBytes(length: 32)
            XCTAssertNil(map[rand], "Failed because duplicate key was generated.")
            map[rand] = true
        }

        XCTAssert(map.count == 10000, "Failed because map count was not equal to 10000.")
    }

    func testSHA512Hashing() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let input = assets["input"] as? String,
            let data = input.data(using: .utf8),
            let expectedOutput = assets["expectedOutput"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        // I know this is testing Apple's SHA function, but it checks that we are using the correct one.
        let output = Data(SHA512.hash(data: data)).map { String(format: "%02hhx", $0) }.joined()
        XCTAssert(output == expectedOutput)
    }

    func testSymmetricAESEncryption() throws {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let expectedResults = assets["expectedResults"] as? [String],
            let key = assets["key"] as? Data,
            let iv = assets["iv"] as? Data
            else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        let sut = try AES256(key: key, iv: iv)

        for i in 0...63 {
            let input = String(repeating: "A", count: i)

            guard let inputData = input.data(using: .utf8) else {
                return XCTFail("Failed to decode input string.")
            }

            let encryptedData = try sut.encrypt(inputData)
            let encryptedString = encryptedData.map { String(format: "%02hhx", $0) }.joined()
            let expectedEncrypted = expectedResults[i]
            XCTAssert(encryptedString == expectedEncrypted, "Failed because encrypted output does not match the expected output.")
            
            let decryptedData = try sut.decrypt(encryptedData)
            let decryptedString = String(data: decryptedData, encoding: .utf8)
            XCTAssert(decryptedString == input, "Failed becasuse decrypted output does not match the original input.")
        }
    }

    func testRSA2048Encryption() throws {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let publicKey = assets["publicKey"] as? String,
            let privateKey = assets["privateKey"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        // Let's run the test a good few times.
        for _ in 0..<64 {
            let input = Crypto.secureRandomData(length: 120)

            let encrypted = try Crypto.encryptRSA(data: input, publicKey: publicKey)
            let decrypted = try Crypto.decryptRSA(data: encrypted, privateKey: privateKey)
            XCTAssertEqual(input, decrypted, "Failed because the RSA2048 encrypted and subsequently decrypted string doesn't match the original input.")

        }
    }
    
    private func setupDataDecryptor() -> DataDecryptor? {
        guard let privateKey = testingAssets["privateKey"] as? String else {
            return nil
        }
        
        let config = Configuration(appId: "testAppId", contractId: "testContractId", privateKey: privateKey)
        return DataDecryptor(configuration: config)
    }
}

