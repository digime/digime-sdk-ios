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
    
    func decrypt(fileContent: Any) throws -> Data {
        if let fileContent = fileContent as? String {
            if let base64Data = Data(base64Encoded: fileContent) {
                return try Crypto.decrypt(encryptedBase64EncodedData: base64Data, privateKey: configuration.privateKey)
            }
            else if let data = fileContent.data(using: .utf8) {
                return data
            }
        }
        else if fileContent is [String: AnyHashable] || fileContent is [AnyHashable] {
            do {
                return try JSONSerialization.data(withJSONObject: fileContent, options: [])
            }
            catch {
                throw SDKError.invalidData
            }
        }
        else if let data = fileContent as? Data {
            return data
        }
        
        throw SDKError.invalidData
    }
}
