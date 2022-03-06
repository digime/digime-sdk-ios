//
//  ServiceType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a service scope with which data requests can be limited to
public struct ServiceType: Encodable {
    public let identifier: UInt
    public let serviceObjectTypes: [ServiceObjectType]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case serviceObjectTypes
    }
    
    /// Limits service-based data response to include this service and associated objects.
    /// A service is a direct or indirect provider of a user's data, such as Twitter or Spotify.
    ///
    /// See https://developers.digi.me/reference-objects#services for a list of service identifiers.
    ///
    /// - Parameters:
    ///   - identifier: The service identifier
    ///   - objectTypes: Objects which can further limit the data request scope for this service. If empty, all objects associated with this service wil be included
    public init(identifier: UInt, objectTypes: [ServiceObjectType]) {
        self.identifier = identifier
        self.serviceObjectTypes = objectTypes
    }
}
