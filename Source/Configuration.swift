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
    let appId: String
    
    /// Your contract identifier
    let contractId: String
    
    /// The PKCS1 private key base 64 encoded data
    let privateKeyData: Data
    
    /// The PKCS1 public key base 64 encoded data
    let publicKeyData: Data?
    
    /// Creates a configuration
    /// - Parameters:
    ///   - appId: Your application identifier
    ///   - contractId: Your contract identifier
    ///   - privateKey: Your PKCS1 private key in PEM format - either with or without the "-----BEGIN RSA PRIVATE KEY-----"  header and "-----END RSA PRIVATE KEY-----" footer
    ///   - publicKey: Your PKCS1 public key in PEM format - either with or without the "-----BEGIN RSA PUBLIC KEY-----"  header and "-----END RSA PUBLIC KEY-----" footer. This is optional and is only used to validate signing using the private key
    public init(appId: String, contractId: String, privateKey: String, publicKey: String? = nil) throws {
        self.appId = appId
        self.contractId = contractId
        self.privateKeyData = try Crypto.base64EncodedData(from: privateKey)
        if let publicKey = publicKey {
            self.publicKeyData = try Crypto.base64EncodedData(from: publicKey)
        }
        else {
            publicKeyData = nil
        }
    }
}
