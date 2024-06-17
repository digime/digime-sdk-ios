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
    public enum CryptoError: Error {
        case stringToDataConversionFailed
        case secKeyCreateFailed(error: CFError)
        case chunkDecryptFailed(index: Int)
        case chunkEncryptFailed(index: Int)
        case dskDecryptFailed(status: OSStatus)
        case corruptData
        case publicKeyDerivationFailed
        case keyConversionFailed(error: CFError)
    }
    
    public static func secureRandomData(length: Int) -> Data {
        Data(secureRandomBytes(length: length))
    }
    
    public static func secureRandomBytes(length: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            Logger.error("Error generating secure random bytes. Status: \(status)")
        }
        
        return bytes
    }
    
    public static func sha256Hash(from dataString: String) -> Data {
        Data(SHA256.hash(data: dataString.data(using: .utf8)!))
    }
	
    public static func md5Hash(from dataString: String) -> String {
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
    
    public static func encrypt(symmetricKey: Data, privateKeyData: Data) throws -> String {
        let publicKeyData = try publicKey(from: privateKeyData)
        let encryptedData = try encryptRSA(data: symmetricKey, publicKeyData: publicKeyData)
        return encryptedData.base64EncodedString(options: .lineLength64Characters)
    }

    public static func encrypt(symmetricKey: Data, publicKey: String) throws -> String {
        let encryptedData = try encryptRSA(data: symmetricKey, publicKey: publicKey)
        return encryptedData.base64EncodedString(options: .lineLength64Characters)
    }
    
    public static func encryptRSA(data: Data, publicKey: String) throws -> Data {
        let publicKeyData = try base64EncodedData(from: publicKey)
        return try encryptRSA(data: data, publicKeyData: publicKeyData)
    }
    
    public static func encryptRSA(data: Data, publicKeyData: Data) throws -> Data {
        let secKey = try secKey(keyData: publicKeyData, isPublic: true)
        return try encryptRSA(data: data, secKey: secKey)
    }
    
    public static func decryptRSA(data: Data, privateKey: String) throws -> Data {
        let privateKeyData = try base64EncodedData(from: privateKey)
        return try decryptRSA(data: data, privateKeyData: privateKeyData)
    }
    
    public static func decryptRSA(data: Data, privateKeyData: Data) throws -> Data {
        let secKey = try secKey(keyData: privateKeyData, isPublic: false)
        return try decryptRSA(data: data, secKey: secKey)
    }
    
    public static func encryptAndAppendHash(inputData data: Data, privateKeyData: Data) throws -> Data {
        let typeDescriptor = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F])
        let mskIndex: UInt32 = 1
        let msk = Crypto.secureRandomData(length: 32)
        
        // Generate random KIV and DSK
        let kiv = Crypto.secureRandomData(length: 16)
        let dsk = Crypto.secureRandomData(length: 32)

        // Encrypt DSK using MSK and KIV
        let aesKIV = try AES256(key: msk, iv: kiv)
        let encryptedDSK = try aesKIV.encrypt(dsk)

        // Generate random DIV
        let div = Crypto.secureRandomData(length: 16)

        // Hash the data using SHA512
        let dataHash = Data(SHA512.hash(data: data))

        // Prepend the hash to the data
        var dataToEncrypt = Data()
        dataToEncrypt.append(dataHash)
        dataToEncrypt.append(data)

        // Encrypt the hash + data using DSK and DIV
        let aesDIV = try AES256(key: dsk, iv: div)
        let encryptedData = try aesDIV.encrypt(dataToEncrypt)

        // Assemble components into one contiguous byte array
        var combinedData = Data()
        combinedData.append(typeDescriptor)
        combinedData.append(withUnsafeBytes(of: mskIndex.bigEndian) { Data($0) }) // Convert MSKI to network-byte-order
        combinedData.append(kiv)
        combinedData.append(encryptedDSK)
        combinedData.append(div)
        combinedData.append(encryptedData)

        return combinedData
    }

    public static func encrypt(inputData data: Data, privateKeyData: Data) throws -> Data {
        // Generate a random symmetric key (Data Symmetric Key - DSK)
        let symmetricKey = secureRandomData(length: kCCKeySizeAES256)

        // Generate a random initialization vector (IV)
        let iv = secureRandomData(length: kCCBlockSizeAES128)

        // Encrypt the input data using AES with the symmetric key and IV
        let aes = try AES256(key: symmetricKey, iv: iv)
        let encryptedFileData = try aes.encrypt(data)

        // Encrypt the symmetric key using RSA with the public key derived from the private key
        let publicKeyData = try publicKey(from: privateKeyData)
        let publicKey = try secKey(keyData: publicKeyData, isPublic: true)
        let encryptedSymmetricKey = try encryptRSA(data: symmetricKey, secKey: publicKey)

        // Combine the encrypted symmetric key, IV, and encrypted file data into one output
        var combinedData = Data()
        combinedData.append(encryptedSymmetricKey)
        combinedData.append(iv)
        combinedData.append(encryptedFileData)

        return combinedData
    }

    public static func decrypt(encryptedBase64EncodedData data: Data, privateKeyData: Data, dataIsHashed: Bool) throws -> Data {
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
    
    public static func secKey(keyData: Data, isPublic: Bool) throws -> SecKey {
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

    public static func publicKey(from privateKeyData: Data) throws -> Data {
        do {
            let privateKey = try secKey(keyData: privateKeyData, isPublic: false)
            guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
                throw CryptoError.publicKeyDerivationFailed
            }

            var error: Unmanaged<CFError>?
            guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
                throw CryptoError.keyConversionFailed(error: error!.takeRetainedValue())
            }

            return keyData
        }
        catch {
            throw error
        }
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
