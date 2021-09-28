//
//  JSONWebKey.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct JSONWebKey: Decodable {
    let e: String // RSA public exponent
    let kid: String // Key identifier
    let kty: String // Key type identifies the cryptographic algorithm family used with the key, such as 'RSA' or 'EC'
    let n: String // RSA Modulus
    let pem: String // PCKS1 public pem encoded public key representation
}
