//
//  ServiceType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ServiceType: Encodable {
    let identifier: UInt
    let serviceObjectTypes: [ServiceObjectType]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case serviceObjectTypes
    }
}
