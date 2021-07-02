//
//  Service.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// A data source
public struct Service: Codable {
    private struct ServiceGroupReference: Codable {
        let identifier: Int
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
        }
    }
    
    private let serviceGroups: [ServiceGroupReference]
    
    /// The service's identifier
    public let identifier: Int
    
    /// The service's name
    public let name: String
    
    
    public var servcieGroupIds: [Int] {
        serviceGroups.map { $0.identifier }
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case serviceGroups
    }
}

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

public struct ServiceCountry: Codable {
    /// The service group's identifier
    public let identifier: Int
    
    /// The service group's name
    public let name: String
    
    public let code: String
        
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case code
    }
}
