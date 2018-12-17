//
//  AccountsContainer.swift
//  DigiMeSDK
//
//  Created on 24/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

struct AccountsContainer: Decodable {
    
    let accounts: [Account]
    let consentID: String
    
    enum CodingKeys: String, CodingKey {
        case accounts
        case consentID = "consentid"
    }
}
