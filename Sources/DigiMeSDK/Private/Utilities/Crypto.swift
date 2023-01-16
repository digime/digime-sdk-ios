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
import Security

public enum Crypto {
    enum CryptoError: Error {
        case stringToDataConversionFailed
        case secKeyCreateFailed(error: CFError)
        case chunkDecryptFailed(index: Int)
        case chunkEncryptFailed(index: Int)
        case dskDecryptFailed(status: OSStatus)
        case corruptData
    }
    
    static func secureRandomData(length: Int) -> Data {
        Data(secureRandomBytes(length: length))
    }
    
    static func secureRandomBytes(length: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            Logger.error("Error generating secure random bytes. Status: \(status)")
        }
        
        return bytes
    }
    
    static func sha256Hash(from dataString: String) -> Data {
        Data(SHA256.hash(data: dataString.data(using: .utf8)!))
    }
	
	static func md5Hash(from dataString: String) -> String {
		return Insecure.MD5.hash(data: dataString.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
	}
    
    public static func base64EncodedData(from pem: String) throws -> Data {
        let strippedKey = pem.filter { !" \n\t\r".contains($0) }
        let base64EncodedString: String
        if strippedKey.contains("-----") {
            let pemComponents = strippedKey.components(separatedBy: "-----")
            guard pemComponents.count == 5 else {
                throw SDKError.invalidPrivateOrPublicKey
            }
            
            base64EncodedString = pemComponents[2]
        }
        else {
            base64EncodedString = strippedKey
        }
        
        guard let data = Data(base64Encoded: base64EncodedString) else {
            throw SDKError.invalidPrivateOrPublicKey
        }
        
        return data
    }
    
    static func encrypt(symmetricKey: Data, publicKey: String) throws -> String {
        let encryptedData = try encryptRSA(data: symmetricKey, publicKey: publicKey)
        return encryptedData.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func encryptRSA(data: Data, publicKey: String) throws -> Data {
        let publicKeyData = try base64EncodedData(from: publicKey)
        return try encryptRSA(data: data, publicKeyData: publicKeyData)
    }
    
    static func encryptRSA(data: Data, publicKeyData: Data) throws -> Data {
        let secKey = try secKey(keyData: publicKeyData, isPublic: true)
        return try encryptRSA(data: data, secKey: secKey)
    }
    
    static func decryptRSA(data: Data, privateKey: String) throws -> Data {
        let privateKeyData = try base64EncodedData(from: privateKey)
        return try decryptRSA(data: data, privateKeyData: privateKeyData)
    }
    
    static func decryptRSA(data: Data, privateKeyData: Data) throws -> Data {
        let secKey = try secKey(keyData: privateKeyData, isPublic: false)
        return try decryptRSA(data: data, secKey: secKey)
    }
    
	static func decrypt(encryptedBase64EncodedData data: Data, privateKeyData: Data, dataIsHashed: Bool) throws -> Data {
        // Split data into components
        let encryptedDskLength = 256
        let divLength = kCCBlockSizeAES128
                
        let encryptedDskRange = data.startIndex..<data.startIndex + encryptedDskLength
        let divRange = encryptedDskRange.endIndex..<encryptedDskRange.endIndex + divLength
        let encryptedFileDataRange = divRange.endIndex..<data.endIndex
        
        let encryptedDsk = data[encryptedDskRange]
        let div = data[divRange]
        let encryptedFileData = data[encryptedFileDataRange]
        
        let dsk = try decryptRSA(data: encryptedDsk, privateKeyData: privateKeyData)
        let aes = try AES256(key: dsk, iv: div)
        let decryptedData = try aes.decrypt(encryptedFileData)
        
		guard dataIsHashed else {
			return decryptedData
		}
		
        // Split decrypted file data into hash and actual data
        let hashLength = SHA512.byteCount
        let hashRange = decryptedData.startIndex..<decryptedData.startIndex + hashLength
        let fileDataRange = hashRange.endIndex..<decryptedData.endIndex
        
        let hash = decryptedData[hashRange]
        let fileData = decryptedData[fileDataRange]
        
        // Check hash
        let calculatedHash = Data(SHA512.hash(data: fileData))
        guard calculatedHash == hash else {
            throw CryptoError.corruptData
        }
        
        return fileData
    }
    
    static func secKey(keyData: Data, isPublic: Bool) throws -> SecKey {
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: keyClass,
            kSecAttrKeySizeInBits: keyData.count * MemoryLayout<UInt8>.size,
            kSecReturnPersistentRef: kCFBooleanTrue as Any,
        ] as CFDictionary
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes, &error) else {
            throw CryptoError.secKeyCreateFailed(error: error!.takeRetainedValue())
        }
        
        return secKey
    }
    
    private static func encryptRSA(data: Data, secKey: SecKey) throws -> Data {
        let blockSize = SecKeyGetBlockSize(secKey)
        
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
            
            let status = SecKeyEncrypt(secKey, .OAEP, chunkData, chunkData.count, &encryptedDataBuffer, &encryptedDataLength)
            
            guard status == noErr else {
                throw CryptoError.chunkEncryptFailed(index: index)
            }
            
            encryptedDataBytes += encryptedDataBuffer
            
            index += maxChunkSize
        }
        
       return Data(bytes: encryptedDataBytes, count: encryptedDataBytes.count)
    }
    
    private static func decryptRSA(data: Data, secKey: SecKey) throws -> Data {
        let blockSize = SecKeyGetBlockSize(secKey)
        var encryptedDataBuffer = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&encryptedDataBuffer, length: data.count)
        
        var decryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var index = encryptedDataBuffer.startIndex
        while index < encryptedDataBuffer.count {
            
            let indexEnd = min(index + blockSize, encryptedDataBuffer.count)
            let chunkData = [UInt8](encryptedDataBuffer[index..<indexEnd])
            
            var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var decryptedDataLength = blockSize
            
            let status = SecKeyDecrypt(secKey, .OAEP, chunkData, indexEnd - index, &decryptedDataBuffer, &decryptedDataLength)
            guard status == noErr else {
                throw CryptoError.chunkDecryptFailed(index: index)
            }
            
            decryptedDataBytes += [UInt8](decryptedDataBuffer[0..<decryptedDataLength])
            
            index += blockSize
        }
        
        return Data(bytes: decryptedDataBytes, count: decryptedDataBytes.count)
    }
}
