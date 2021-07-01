//
//  Account.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// A data source
public struct Account: Codable {
    
    /// The account's identifier
    public let identifier: String
    
    /// The account's name
    public let name: String
    
    public let number: String? // which accounts have this?
    
    public let service: ServiceDescriptor

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case number
        case service
    }
}

public struct ServiceDescriptor: Codable {
    public let name: String
    public let logo: String?
}

public struct AccountsInfo: Codable {
    public let accounts: [Account]
    public let consentId: String
    
    enum CodingKeys: String, CodingKey {
        case accounts
        case consentId = "consentid"
    }
}
