//
//  ServiceObjectType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ServiceObjectType: Encodable {
    let identifier: UInt
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}
