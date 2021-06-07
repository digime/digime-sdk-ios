//
//  ServiceGroup.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 diig.me Limited. All rights reserved.
//

import Foundation

struct ServiceGroup: Encodable {
    let identifier: UInt
    let serviceTypes: [ServiceType]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case serviceTypes
    }
}
