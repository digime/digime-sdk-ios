//
//  AccountsInfo.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Details which service data source accounts the user has added.
public struct AccountsInfo: Codable {
    
    /// List of accounts user has added
    public let accounts: [SourceAccount]
    
    /// The consent identifier
    public let consentId: String
    
    enum CodingKeys: String, CodingKey {
        case accounts
        case consentId = "consentid"
    }
}
