//
//  OAuthToken.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct OAuthToken: Codable {
    public struct Token: Codable {
        let expiry: Date
        public let value: String
        
        enum CodingKeys: String, CodingKey {
            case expiry = "expires_on"
            case value
        }
        
        public var isValid: Bool {
            expiry > Date()
        }
    }
    
    struct Identifier: Codable {
        let id: String
    }
    
    public let accessToken: Token
    public let refreshToken: Token
    let identifier: Identifier
    let consentId: String
    let tokenType: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case identifier
        case consentId = "consentid"
        case tokenType = "token_type"
        case userId = "sub"
    }
}
