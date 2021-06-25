//
//  Crypto.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import CommonCrypto
import CryptoKit
import Foundation

enum Crypto {
    enum CryptoError: Error {
        case stringToDataConversionFailed
        case secKeyCreateFailed(error: CFError)
        case chunkDecryptFailed(index: Int)
        case chunkEncryptFailed(index: Int)
        case dskDecryptFailed(status: OSStatus)
        case corruptData
    }
    
    static func secureRandomData(length: Int) -> Data {
        Data(bytes: secureRandomBytes(length: length))
    }
    
    static func secureRandomBytes(length: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            NSLog("Error generating secure random bytes. Status: \(status)")
        }
        
        return bytes
    }
    
    static func encrypt(symmetricKey: Data, publicKey: String) throws -> String {
        let encryptedData = try encryptRSA(data: symmetricKey, publicKey: publicKey)
        return encryptedData.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func encryptRSA(data: Data, publicKey: String) throws -> Data {
        let keyString = publicKey.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "").replacingOccurrences(of: "\n-----END PUBLIC KEY-----", with: "")
        guard let keyData = Data(base64Encoded: keyString) else {
            throw CryptoError.stringToDataConversionFailed
        }
        
        let secKey = try secKey(keyData: keyData, isPublic: true)
        
        return try encryptRSA(data: data, publicKey: secKey)
    }
    
    static func decryptRSA(data: Data, privateKey: String) throws -> Data {
        let keyString = privateKey.replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----\n", with: "").replacingOccurrences(of: "\n-----END PRIVATE KEY-----", with: "").replacingOccurrences(of: "\n", with: "")
        guard let keyData = Data(base64Encoded: keyString) else {
            throw CryptoError.stringToDataConversionFailed
        }
        
        let secKey = try secKey(keyData: keyData, isPublic: false)
        
        return try decryptRSA(data: data, privateKey: secKey)
    }
    
    static func decrypt(encryptedBase64EncodedData data: Data, privateKey: String) throws -> Data {
        // Split data into components
        let encryptedDskLength = 256
        let divLength = kCCBlockSizeAES128
                
        let encryptedDskRange = data.startIndex..<data.startIndex + encryptedDskLength
        let divRange = encryptedDskRange.endIndex..<encryptedDskRange.endIndex + divLength
        let encryptedFileDataRange = divRange.endIndex..<data.endIndex
        
        let encryptedDsk = data[encryptedDskRange]
        let div = data[divRange]
        let encryptedFileData = data[encryptedFileDataRange]
        
        let dsk = try decryptRSA(data: encryptedDsk, privateKey: privateKey)
        let aes = try AES256(key: dsk, iv: div)
        let fileDataWithHash = try aes.decrypt(encryptedFileData)
        
        // Split decrypted file data into hash and actual data
        let hashLength = SHA512.byteCount
        let hashRange = fileDataWithHash.startIndex..<fileDataWithHash.startIndex + hashLength
        let fileDataRange = hashRange.endIndex..<fileDataWithHash.endIndex
        
        let hash = fileDataWithHash[hashRange]
        let fileData = fileDataWithHash[fileDataRange]
        
        // Check hash
        let calculatedHash = Data(SHA512.hash(data: fileData))
        guard calculatedHash == hash else {
            throw CryptoError.corruptData
        }
        
        return fileData
    }
    
    private static func secKey(keyData: Data, isPublic: Bool) throws -> SecKey {
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: keyClass,
            kSecAttrKeySizeInBits: keyData.count * 8,
            kSecReturnPersistentRef: kCFBooleanTrue,
        ] as CFDictionary
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes, &error) else {
            throw CryptoError.secKeyCreateFailed(error: error!.takeRetainedValue())
        }
        
        return secKey
    }
    
    private static func encryptRSA(data: Data, publicKey: SecKey) throws -> Data {
        var blockSize = SecKeyGetBlockSize(publicKey)
        
        let maxChunkSize = blockSize - 42 // For OAEP padding
        
        var decryptedDataBuffer = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&decryptedDataBuffer, length: data.count)
        
        var encryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var index = decryptedDataBuffer.startIndex
        while index < decryptedDataBuffer.count {
            
            let indexEnd = min(index + maxChunkSize, decryptedDataBuffer.count)
            let chunkData = [UInt8](decryptedDataBuffer[index..<indexEnd])
            
            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize
            
            let status = SecKeyEncrypt(publicKey, .OAEP, chunkData, chunkData.count, &encryptedDataBuffer, &encryptedDataLength)
            
            guard status == noErr else {
                throw CryptoError.chunkEncryptFailed(index: index)
            }
            
            encryptedDataBytes += encryptedDataBuffer
            
            index += maxChunkSize
        }
        
       return Data(bytes: encryptedDataBytes, count: encryptedDataBytes.count)
    }
    
    private static func decryptRSA(data: Data, privateKey: SecKey) throws -> Data {
        let blockSize = SecKeyGetBlockSize(privateKey)
        var encryptedDataBuffer = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&encryptedDataBuffer, length: data.count)
        
        var decryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var index = encryptedDataBuffer.startIndex
        while index < encryptedDataBuffer.count {
            
            let indexEnd = min(index + blockSize, encryptedDataBuffer.count)
            let chunkData = [UInt8](encryptedDataBuffer[index..<indexEnd])
            
            var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var decryptedDataLength = blockSize
            
            let status = SecKeyDecrypt(privateKey, .OAEP, chunkData, indexEnd - index, &decryptedDataBuffer, &decryptedDataLength)
            guard status == noErr else {
                throw CryptoError.chunkDecryptFailed(index: index)
            }
            
            decryptedDataBytes += [UInt8](decryptedDataBuffer[0..<decryptedDataLength])
            
            index += blockSize
        }
        
        return Data(bytes: decryptedDataBytes, count: decryptedDataBytes.count)
    }
}
