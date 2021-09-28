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
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
    
    /// Limits service-based data response to include this object.
    /// An object is a distinct piece of user data retrieved from a service, such as social media Post, a afitness Activity, or financial Transaction.
    ///
    /// See https://developers.digi.me/reference-objects#objects for a list of object identifiers.
    ///
    /// - Parameter identifier: The object identifier
    public init(identifier: UInt) {
        self.identifier = identifier
    }
}
