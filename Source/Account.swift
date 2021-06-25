//
//  Account.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// A data source
public struct Account {
    
    /// The account's identifier
    let identifier: String
    
    /// The account's name
    let name: String
    
    let number: String
    
    let service: ServiceDescriptor
}

public struct ServiceDescriptor {
    let name: String
    let logo: String?
}

public struct AccountList {
    let fileId: String
    let accounts: [Account]
}
