//
//  ServiceGroup.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Describes the group for a service data source
public struct ServiceGroup: Codable {
    /// The service group's identifier
    public let identifier: Int
    
    /// The service group's name
    public let name: String
        
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
    }
}
