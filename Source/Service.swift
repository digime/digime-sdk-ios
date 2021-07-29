//
//  Service.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Info for services and related groups
public struct ServicesInfo: Decodable {
    public let countries: [ServiceCountry]
    public let serviceGroups: [ServiceGroup]
    public let services: [Service]
}

/// A data source
public struct Service: Codable {
    /// The service's identifier for authorization
    public let identifier: Int
    
    /// The service's identifier for scoping data requests
    ///
    /// This differs to the identifier for authorization because multiple services
    /// may share the same `serviceIdentifier` but each have a different authorization identifier.
    public let serviceIdentifier: Int
    
    /// The service's name
    public let name: String
    
    /// The identifiers of the service group this service belongs to
    public var serviceGroupIds: [Int] {
        serviceGroups.map { $0.identifier }
    }
    
    var isAvailable: Bool {
        return publishedStatus == "approved" && platform.isAvailable
    }
    
    private let serviceGroups: [ServiceGroupReference]
    
    private struct ServiceGroupReference: Codable {
        let identifier: Int
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
        }
    }
    
    private let publishedStatus: String // approved, blocked, pending, or deprecated
    
    private let platform: Platform
    private struct Platform: Codable {
        private let windows: PlatformAvailablility
        
        private struct PlatformAvailablility: Codable {
            let availability: String // production, demo, beta, none
            let currentStatus: String // available, unavailable
        }
        
        var isAvailable: Bool {
            return windows.availability == "production" && windows.currentStatus == "available"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case serviceGroups
        case serviceIdentifier = "serviceId"
        case publishedStatus
        case platform
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
