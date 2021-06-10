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
    
    /// Your PKCS1 private key - the bits between "-----BEGIN RSA PRIVATE KEY-----" and "-----END RSA PRIVATE KEY-----"
    let privateKey: String
    
    /// Your PKCS1 public key - the bits between "-----BEGIN RSA PUBLIC KEY-----" and "-----END RSA PUBLIC KEY-----"
    let publicKey: String?
    
    public init(appId: String, contractId: String, privateKey: String, publicKey: String? = nil) {
        self.appId = appId
        self.contractId = contractId
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
