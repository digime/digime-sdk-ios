//
//  ServiceGroupType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a service group scope with which data requests can be limited to
public struct ServiceGroupType: Codable, Identifiable {
    public let id: Int
    public let serviceTypes: [ServiceType]
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case serviceTypes
        case name
    }
    
    /// Limits service-based data response to a service group and associated services.
    /// A service group is a top level category grouping similar services, such as Social, Fitness, etc.
    ///
    /// See https://developers.digi.me/reference-objects#service-group for a list of service group identifiers.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the service group.
    ///   - serviceTypes: The service types to additionally limit data response to. If an empty array is passed, all services associated with service group will be included
    ///   - name: The object name. Convenience property.
    public init(identifier: Int, serviceTypes: [ServiceType], name: String? = nil) {
        self.id = identifier
        self.serviceTypes = serviceTypes
        self.name = name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(serviceTypes, forKey: .serviceTypes)
    }
}
