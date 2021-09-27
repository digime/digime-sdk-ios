//
//  Configuration.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// SDK Configuration
public struct Configuration {
    
    /// Your application identifier
    public let appId: String
    
    /// Your contract identifier
    public let contractId: String
    
    /// The PKCS1 private key base 64 encoded data
    public  let privateKeyData: Data
    
    /// Creates a configuration
    /// - Parameters:
    ///   - appId: Your application identifier
    ///   - contractId: Your contract identifier
    ///   - privateKey: Your PKCS1 private key in PEM format - either with or without the "-----BEGIN RSA PRIVATE KEY-----"  header and "-----END RSA PRIVATE KEY-----" footer
    public init(appId: String, contractId: String, privateKey: String) throws {
        self.appId = appId
        self.contractId = contractId
        self.privateKeyData = try Crypto.base64EncodedData(from: privateKey)
    }
}
