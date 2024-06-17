//
//  CryptographyTests.swift
//  DigiMeSDKExampleTests
//
//  Created on 19/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import CryptoKit
import DigiMeCore
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
    
    func testReadJSONFile2() throws {
        // Ensure the test bundle is loaded
        let testBundle = Bundle(for: type(of: self))

        // Locate the JSON file in the test bundle
        guard let fileURL = testBundle.url(forResource: "test-decrypted", withExtension: "json") else {
            XCTFail("JSON file 'test-decrypted.json' not found in the test bundle")
            return
        }

        do {
            // Read the contents of the file
            let data = try Data(contentsOf: fileURL)

            // Decode the JSON data
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

            // Validate the JSON structure
            if let jsonArray = jsonObject as? [[String: Any]] {
                // Extract the first dictionary from the array
                guard let jsonDict = jsonArray.first else {
                    XCTFail("JSON array is empty")
                    return
                }

                // Extract the 'id' value from the dictionary
                guard let value = jsonDict["id"] as? String else {
                    XCTFail("'id' key not found or value is not a string")
                    return
                }

                // Assert that the 'id' value matches the expected value
                XCTAssertEqual(value, "A09286BD-05D3-421A-A607-6D09B8AABCB2", "The 'id' value does not match the expected value")
            }
            else {
                XCTFail("JSON structure is invalid or not an array of dictionaries")
            }
        }
        catch {
            XCTFail("Failed to read or decode JSON file: \(error)")
        }
    }

    func testReadJSONFile() throws {
        // Ensure the test bundle is loaded
        let testBundle = Bundle(for: type(of: self))

        // Locate the JSON file in the test bundle
        guard 
            let fileURL = testBundle.url(forResource: "AH_Respiratory_Rate_2024-April-2024-May_items_100", withExtension: "json"),
            let privateKey = testingAssets["privateKeyDevelopment"] as? String else {
            XCTFail("JSON file not found in the test bundle")
            return
        }

        do {
            // Read the contents of the file
            let data = try Data(contentsOf: fileURL)

            // Decode the JSON data
            let _ = try JSONSerialization.jsonObject(with: data, options: [])
            let privateKeyData = try Crypto.base64EncodedData(from: privateKey)
            let _ = try Crypto.encrypt(inputData: data, privateKeyData: privateKeyData)
        }
        catch {
            XCTFail("Failed to read or decode JSON file: \(error)")
        }
    }

    func testDecryptingAndEncryptingData() {
        let testBundle = Bundle(for: type(of: self))

        // Load required testing assets: encrypted input, decrypted input, and private key
        guard
            let encryptedInputFileURL = testBundle.url(forResource: "test-encrypted", withExtension: "json"),
            let encryptedInput = try? Data(contentsOf: encryptedInputFileURL),
            let decryptedInputFileURL = testBundle.url(forResource: "test-decrypted", withExtension: "json"),
            let decryptedInput = try? Data(contentsOf: decryptedInputFileURL),
            let privateKey = testingAssets["privateKeyIntegration"] as? String
        else {
            return XCTFail("Failed to load required testing assets.")
        }

        do {
            // Convert private key to data
            let privateKeyData = try Crypto.base64EncodedData(from: privateKey)

            // Decrypt the encrypted input
            let decryptedOutput = try Crypto.decrypt(encryptedBase64EncodedData: encryptedInput, privateKeyData: privateKeyData, dataIsHashed: false)

            // Assert that decrypted data matches the expected decrypted input
            XCTAssertEqual(decryptedInput, decryptedOutput, "Decrypted output does not match the expected decrypted input.")

            // Deserialize decrypted output and input into JSON objects
            let decryptedOutputJsonObject = try? JSONSerialization.jsonObject(with: decryptedOutput, options: [.allowFragments])
            let inputJsonObject = try? JSONSerialization.jsonObject(with: decryptedInput, options: [.allowFragments])

            // Assert that the JSON objects are equal
            XCTAssertTrue(areEqualArrays(decryptedOutputJsonObject as! [[String: Any]], inputJsonObject as! [[String: Any]]), "Decrypted JSON object does not match the expected JSON object.")

            // Encrypt the decrypted output again to verify the encryption process
            let encryptedVerify = try Crypto.encrypt(inputData: decryptedOutput, privateKeyData: privateKeyData)

            // Assert that the size of the re-encrypted data matches the original encrypted input
            XCTAssertEqual(encryptedInput.count, encryptedVerify.count, "Re-encrypted data size does not match the original encrypted input size.")

            // Decrypt the re-encrypted data to verify the decryption process
            let decryptedVerify = try Crypto.decrypt(encryptedBase64EncodedData: encryptedVerify, privateKeyData: privateKeyData, dataIsHashed: false)

            // Assert that the re-decrypted data matches the expected decrypted input
            XCTAssertEqual(decryptedInput.hashValue, decryptedVerify.hashValue, "Re-decrypted data does not match the expected decrypted input.")
        }
        catch {
            XCTFail("Failed to decrypt or encrypt data. \(error)")
        }
    }

    func testDataDecryptorEncrypted2() {
        let testBundle = Bundle(for: type(of: self))

        guard
            let encryptedInputFileURL = testBundle.url(forResource: "test-encrypted", withExtension: "json"),
            let encryptedInput = try? Data(contentsOf: encryptedInputFileURL),
            let decryptedInputFileURL = testBundle.url(forResource: "test-decrypted", withExtension: "json"),
            let decryptedInput = try? Data(contentsOf: decryptedInputFileURL),
            let privateKey = testingAssets["privateKeyIntegration"] as? String
        else {
            return XCTFail("Failed to load required testing assets.")
        }

        do {
            let privateKeyData = try Crypto.base64EncodedData(from: privateKey)
            let decryptedOutput = try Crypto.decrypt(encryptedBase64EncodedData: encryptedInput, privateKeyData: privateKeyData, dataIsHashed: false)
            XCTAssertEqual(decryptedInput, decryptedOutput, "Failed to decrypt encrypted data.")

            let decryptedOutputJsonObject = try? JSONSerialization.jsonObject(with: decryptedOutput, options: [.allowFragments])
            let inputJsonObject = try? JSONSerialization.jsonObject(with: decryptedInput, options: [.allowFragments])
            XCTAssertTrue(areEqualArrays(decryptedOutputJsonObject as! [[String: Any]], inputJsonObject as! [[String: Any]]), "Decrypted JSON object does not match the expected JSON object.")

            let encryptedVerify = try Crypto.encrypt(inputData: decryptedOutput, privateKeyData: privateKeyData)
            XCTAssertEqual(encryptedInput.count, encryptedVerify.count, "Failed to encrypt decrypted data.")

            let decryptedVerify = try Crypto.decrypt(encryptedBase64EncodedData: encryptedVerify, privateKeyData: privateKeyData, dataIsHashed: false)
            XCTAssertEqual(decryptedInput, decryptedVerify, "Failed to decrypt encrypted data.")
        }
        catch {
            XCTFail("Decrypt file content failed. \(error)")
        }
    }

    func testDataDecryptorEncrypted() {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let input = assets["input"] as? String,
            let data = Data(base64Encoded: input),
            let expectedResult = assets["expectedResult"] as? Data,
            let privateKey = testingAssets["privateKey"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }

        do {
            let dataDecryptor = try setupDataDecryptor(privateKey: privateKey)

            let fileInfo = try Data(base64URLEncoded: "e30")!.decoded() as FileInfo
            let response = FileResponse(data: data, info: fileInfo)

			let output = try dataDecryptor.decrypt(response: response, dataIsHashed: true)
            XCTAssert(expectedResult == output, "Failed to decrypt encrypted data.")
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
    
    func testKeyDataConversion() throws {
        guard
            let assets = testingAssets[#function] as? [AnyHashable: Any],
            let publicKey = assets["publicKey"] as? String,
            let publicKeyNoBreaks = assets["publicKeyNoBreaks"] as? String,
            let publicKeyNoHeaderFooter = assets["publicKeyNoHeaderFooter"] as? String,
            let publicKeyNoHeaderFooterOrBreaks = assets["publicKeyNoHeaderFooterOrBreaks"] as? String,
            let publicKeyRandomWhitespace = assets["publicKeyRandomWhitespace"] as? String,
            let privateKey = assets["privateKey"] as? String,
            let privateKeyNoBreaks = assets["privateKeyNoBreaks"] as? String,
            let privateKeyNoHeaderFooter = assets["privateKeyNoHeaderFooter"] as? String,
            let privateKeyNoHeaderFooterOrBreaks = assets["privateKeyNoHeaderFooterOrBreaks"] as? String,
            let privateKeyRandomWhitespace = assets["privateKeyRandomWhitespace"] as? String
            else {
                return XCTFail("Failed to load required testing assets.")
        }
        
        let publicKeyData = try Crypto.base64EncodedData(from: publicKey)
        let publicKeyNoBreaksData = try Crypto.base64EncodedData(from: publicKeyNoBreaks)
        let publicKeyNoHeaderFooterData = try Crypto.base64EncodedData(from: publicKeyNoHeaderFooter)
        let publicKeyNoHeaderFooterOrBreaksData = try Crypto.base64EncodedData(from: publicKeyNoHeaderFooterOrBreaks)
        let publicKeyRandomWhitespaceData = try Crypto.base64EncodedData(from: publicKeyRandomWhitespace)
        
        XCTAssertEqual(publicKeyData, publicKeyNoBreaksData)
        XCTAssertEqual(publicKeyData, publicKeyNoHeaderFooterData)
        XCTAssertEqual(publicKeyData, publicKeyNoHeaderFooterOrBreaksData)
        XCTAssertEqual(publicKeyData, publicKeyRandomWhitespaceData)
        
        let privateKeyData = try Crypto.base64EncodedData(from: privateKey)
        let privateKeyNoBreaksData = try Crypto.base64EncodedData(from: privateKeyNoBreaks)
        let privateKeyNoHeaderFooterData = try Crypto.base64EncodedData(from: privateKeyNoHeaderFooter)
        let privateKeyNoHeaderFooterOrBreaksData = try Crypto.base64EncodedData(from: privateKeyNoHeaderFooterOrBreaks)
        let privateKeyRandomWhitespaceData = try Crypto.base64EncodedData(from: privateKeyRandomWhitespace)
        
        XCTAssertEqual(privateKeyData, privateKeyNoBreaksData)
        XCTAssertEqual(privateKeyData, privateKeyNoHeaderFooterData)
        XCTAssertEqual(privateKeyData, privateKeyNoHeaderFooterOrBreaksData)
        XCTAssertEqual(privateKeyData, privateKeyRandomWhitespaceData)
    }
    
    private func setupDataDecryptor(privateKey: String) throws -> DataDecryptor {
        let config = try Configuration(appId: "testAppId", contractId: "testContractId", privateKey: privateKey)
        return DataDecryptor(configuration: config)
    }
}

