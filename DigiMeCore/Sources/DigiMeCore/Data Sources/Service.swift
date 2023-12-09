//
//  Service.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Information about a service data source
public struct Service: Codable, Identifiable {
	public let id = UUID()
	
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
    
    /// The identifiers of the countries this service belongs to
    public var countryIds: [Int] {
        countries.map { $0.identifier }
    }
    
    /// Convenience property to encapsulate read options within the each service
    public var options: ReadOptions?
	public var resources: [DiscoveryResource]
    public var security: ConnectionSecurity?
    public var isAvailable: Bool {
        return publishedStatus == "approved" && platform.isAvailable
    }
    
    public init(identifier: Int, serviceIdentifier: Int, name: String, options: ReadOptions? = nil, resources: [DiscoveryResource], countries: [IdentifierReference], serviceGroups: [IdentifierReference], publishedStatus: String, platform: Platform) {
        self.identifier = identifier
        self.serviceIdentifier = serviceIdentifier
        self.name = name
        self.options = options
        self.resources = resources
        self.countries = countries
        self.serviceGroups = serviceGroups
        self.publishedStatus = publishedStatus
        self.platform = platform
    }
    
    private let countries: [IdentifierReference]
    private let serviceGroups: [IdentifierReference]
    
    public struct IdentifierReference: Codable {
        let identifier: Int
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
        }
    }
    
    public var sampleDataOnly: Bool {
        return publishedStatus == "sampledataonly"
    }
    
    private let publishedStatus: String // approved, blocked, pending, sampledataonly or deprecated
    
    private let platform: Platform
    public struct Platform: Codable {
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
		case id = "uuid"
        case identifier = "id"
        case name
        case serviceGroups
        case serviceIdentifier = "serviceId"
        case publishedStatus
        case platform
        case countries
		case resources
    }
}

extension Service: Equatable {
    public static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.id == rhs.id
    }
}
