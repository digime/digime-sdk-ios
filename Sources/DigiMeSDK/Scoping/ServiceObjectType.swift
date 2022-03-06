//
//  ServiceObjectType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents an object scope with which data requests can be limited to
public struct ServiceObjectType: Encodable {
    public let identifier: UInt
    /// convenience property
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
    }
    
    /// Limits service-based data response to include this object.
    /// An object is a distinct piece of user data retrieved from a service, such as social media Post, a afitness Activity, or financial Transaction.
    ///
    /// See https://developers.digi.me/reference-objects#objects for a list of object identifiers.
    ///
    /// - Parameter identifier: The object identifier
    /// - Parameter name: The object name
    public init(identifier: UInt, name: String? = nil) {
        self.identifier = identifier
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(UInt.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
    }
}
