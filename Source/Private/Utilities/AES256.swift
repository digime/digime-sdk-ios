//
//  AES256.swift
//  DigiMeSDK
//
//  Created on 16/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import CommonCrypto
import Foundation

struct AES256 {
    private let key: Data
    private let iv: Data
    
    enum AESError: Error {
        case invalidKeyLength
        case invalidInitializationVectorLength
        case cryptFailed(status: CCCryptorStatus)
    }
    
    init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw AESError.invalidKeyLength
        }
        
        guard iv.count == kCCBlockSizeAES128 else {
            throw AESError.invalidInitializationVectorLength
        }
        
        self.key = key
        self.iv = iv
    }
    
    static func generateSymmetricKey() -> Data {
        Crypto.secureRandomData(length: kCCKeySizeAES256)
    }
    
    static func generateInitializationVector() -> Data {
        Crypto.secureRandomData(length: kCCBlockSizeAES128)
    }
    
    /// Encrypt with AES-CBC algorithm
    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }
    
    /// Decrypt with AES-CBC algorithm
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }
    
    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outputBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var numBytesWritten = 0
        var status = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes { rawBufferPointer in
            let inputBytes = rawBufferPointer.baseAddress!
            
            iv.withUnsafeBytes { rawBufferPointer in
                let ivBytes = rawBufferPointer.baseAddress!
                
                key.withUnsafeBytes { rawBufferPointer in
                    let keyBytes = rawBufferPointer.baseAddress!
                    
                    status = CCCrypt(
                        operation,                         // operation
                        CCAlgorithm(kCCAlgorithmAES128),   // algorithm
                        CCOptions(kCCOptionPKCS7Padding),  // options
                        keyBytes,                          // key
                        key.count,                         // keylength
                        ivBytes,                           // iv
                        inputBytes,                        // dataIn
                        input.count,                       // dataInLength
                        &outputBytes,                      // dataOut
                        outputBytes.count,                 // dataOutAvailable
                        &numBytesWritten                   // dataOutMoved
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw AESError.cryptFailed(status: status)
        }
        
        outputBytes.removeSubrange(numBytesWritten..<outputBytes.count) // trim extra padding
        return Data(outputBytes)
    }
}
