//
//  Account.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// A data source
public struct Account: Decodable {
    
    /// The account's identifier
    let `id`: String
    
    /// The account's name
    let name: String
    
    let number: String? // which accounts have this?
    
    let service: ServiceDescriptor
}

public struct ServiceDescriptor: Decodable {
    let name: String
    let logo: String?
}

public struct AccountsInfo: Decodable {
    let accounts: [Account]
    let consentid: String
}
