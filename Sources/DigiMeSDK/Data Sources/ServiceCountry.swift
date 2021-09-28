//
//  ServiceCountry.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Describes a country for a service data source
public struct ServiceCountry: Codable {
    /// The country's identifier
    public let identifier: Int
    
    /// The country's name
    public let name: String
    
    /// The country code
    public let code: String
        
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case code
    }
}
