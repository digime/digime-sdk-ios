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
    
    /// Your PKCS1 private key
    let privateKey: String
    
    /// Your PKCS1 public key
    let publicKey: String?
}
