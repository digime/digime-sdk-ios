//
//  Credentials.swift
//  DigiMeSDK
//
//  Created on 18/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Credentials for accessing user's digi.me library
public struct Credentials: Codable {
    public let accountReference: String?
    
    let token: OAuthToken
    let writeAccessInfo: WriteAccessInfo?
    
    init(token: OAuthToken, writeAccessInfo: WriteAccessInfo? = nil, accountReference: String? = nil) {
        self.token = token
        self.writeAccessInfo = writeAccessInfo
        self.accountReference = accountReference
    }
}
