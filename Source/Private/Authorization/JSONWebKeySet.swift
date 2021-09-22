//
//  JSONWebKeySet.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct JSONWebKeySet: Decodable {
    let keys: [JSONWebKey]
    let date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case keys
    }
    
    // Cache for 15 minutes
    var isValid: Bool {
        Date() < date.addingTimeInterval(15 * 60)
    }
}
