//
//  DataDecryptor.swift
//  DigiMeSDK
//
//  Created on 17/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

class DataDecryptor {
    private let configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func decrypt(response: FileResponse) throws -> Data {
        do {
            var unpackedData = try Crypto.decrypt(encryptedBase64EncodedData: response.data, privateKeyData: configuration.privateKeyData)
            if response.info.compression == "gzip" {
                unpackedData = try DataCompressor.gzip.decompress(data: unpackedData)
            }
            
            return unpackedData
        }
        catch {
            throw SDKError.invalidData
        }
    }
}
