//
//  ServiceType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a service scope with which data requests can be limited to
public struct ServiceType: Codable, Identifiable {
    public let id: Int
    public let serviceObjectTypes: [ServiceObjectType]
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case serviceObjectTypes
        case name
    }
    
    /// Limits service-based data response to include this service and associated objects.
    /// A service is a direct or indirect provider of a user's data, such as Twitter or Spotify.
    ///
    /// See https://developers.digi.me/reference-objects#services for a list of service identifiers.
    ///
    /// - Parameters:
    ///   - identifier: The service identifier
    ///   - objectTypes: Objects which can further limit the data request scope for this service. If empty, all objects associated with this service wil be included
    ///   - name: The object name. Convenience property.
    public init(identifier: Int, objectTypes: [ServiceObjectType], name: String? = nil) {
        self.id = identifier
        self.serviceObjectTypes = objectTypes
        self.name = name
    }
     
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(serviceObjectTypes, forKey: .serviceObjectTypes)
    }
}
