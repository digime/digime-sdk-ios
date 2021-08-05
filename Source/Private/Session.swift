//
//  Session.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct Session: Codable {
    let expiry: Double // timestamp in milliseconds since 1970
    let key: String
    
    var isValid: Bool {
        // Allow at least one minute before expiry
        expiry > (Date().timeIntervalSince1970 * 1000 + 60)
    }
}
