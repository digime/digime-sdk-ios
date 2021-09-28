//
//  JWTClaims.swift
//  DigiMeSDK
//
//  Created on 22/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

protocol JWTClaims: Codable {
    func encode() throws -> String
}

extension JWTClaims {
    func encode() throws -> String {
        let data = try self.encoded(dateEncodingStrategy: .secondsSince1970)
        return data.base64URLEncodedString()
    }
}
