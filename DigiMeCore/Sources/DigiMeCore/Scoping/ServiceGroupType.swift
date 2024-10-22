//
//  ServiceGroupType.swift
//  DigiMeCore
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a service group scope with which data requests can be limited to
public struct ServiceGroupType: Codable, Identifiable {
    public var id: Int
    public var name: String?
    public var serviceTypes: [ServiceType]?
    
    /// Initializes a new instance of `ServiceGroupType`.
    ///
    /// A service group is a top-level category grouping similar services, such as Social, Fitness, etc.
    /// This initializer sets up a service group with specific characteristics and metadata that can be used
    /// to further define or restrict the service group's behavior in the application.
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier for the service group. This is used to uniquely identify the group within the system.
    ///   - name: An optional name for the service group. This is a convenience property that can be used to display a human-readable name for the group.
    ///   - serviceTypes: An optional array of `ServiceType` objects associated with the service group. If an empty array is passed, or the parameter is nil, all services associated with the group will be included.
    ///
    /// See https://developers.digi.me/reference-objects#service-group for a list of service group identifiers.
    public init(identifier: Int, name: String? = nil, serviceTypes: [ServiceType]? = nil) {
        self.id = identifier
        self.name = name
        self.serviceTypes = serviceTypes
    }
}

public struct ServiceGroupMetadata: Codable {
    public var expandedSubTitle: String
    public var expandedTitle: String
    public var subTitle: String
    public var title: String
}
