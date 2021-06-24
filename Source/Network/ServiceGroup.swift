//
//  ServiceGroup.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct ServiceGroup: Encodable {
    let identifier: UInt
    let serviceTypes: [ServiceType]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case serviceTypes
    }
}
