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
    
    func decrypt(data: Data, fileInfo: FileInfo) throws -> Data {
        var unpackedData = try Crypto.decrypt(encryptedBase64EncodedData: data, privateKeyData: configuration.privateKeyData)
        if fileInfo.compression == "gzip" {
            unpackedData = try DataCompressor.gzip.decompress(data: unpackedData)
        }
        
        return unpackedData
    }
}
