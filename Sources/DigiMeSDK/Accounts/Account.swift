//
//  Account.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// The account relating to a service data source user has added to digi.me library
public struct Account: Codable {
    
    /// The account's identifier
    public let identifier: String
    
    /// The account's name
    public let name: String?
    
    /// The account number
    public let number: String?
    
    /// The description of service account realtes to
    public let service: AccountServiceDescriptor

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case number
        case service
    }
}
