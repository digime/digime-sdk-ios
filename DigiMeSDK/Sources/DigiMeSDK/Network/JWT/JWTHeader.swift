//
//  JWTHeader.swift
//  DigiMeSDK
//
//  Created on 22/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// This header only contains the properties the SDK is interested in.
struct JWTHeader: Codable {
    let typ: String?
    let alg: String?
    let jku: String?
    let kid: String?
    
    init(
        typ: String? = "JWT",
        alg: String? = nil,
        jku: String? = nil,
        kid: String? = nil
    ) {
        self.typ = typ
        self.alg = alg
        self.jku = jku
        self.kid = kid
    }
    
    func encode() throws -> String {
        let data = try self.encoded()
        return data.base64URLEncodedString()
    }
}
