//
//  ServiceGroupScope.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a service group scope with which data requests can be limited to
public struct ServiceGroupScope: Encodable {
    public let identifier: UInt
    public let serviceTypes: [ServiceType]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case serviceTypes
    }
    
    /// Limits service-based data response to a service group and associated services.
    /// A service group is a top level category grouping similar services, such as Social, Fitness, etc.
    ///
    /// See https://developers.digi.me/reference-objects#service-group for a list of service group identifiers.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the service group.
    ///   - serviceTypes: The service types to additionally limit data response to. If an empty array is passed, all services associated with service group will be included
    public init(identifier: UInt, serviceTypes: [ServiceType]) {
        self.identifier = identifier
        self.serviceTypes = serviceTypes
    }
}
