//
//  DataDecryptor.swift
//  DigiMeSDK
//
//  Created on 17/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class DataDecryptor {
    private let configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
	func decrypt(response: FileResponse, dataIsHashed: Bool) throws -> Data {
        do {
			var unpackedData = try Crypto.decrypt(encryptedBase64EncodedData: response.data, privateKeyData: configuration.privateKeyData, dataIsHashed: dataIsHashed)
            if response.info.compression == "gzip" {
                unpackedData = try DataCompressor.gzip.decompress(data: unpackedData)
            }
            
            return unpackedData
        }
		catch let error as Crypto.CryptoError {
			throw error
		}
		catch let error as SDKError {
			throw error
		}
        catch {
            throw SDKError.errorDecryptingResponse
        }
    }
}
