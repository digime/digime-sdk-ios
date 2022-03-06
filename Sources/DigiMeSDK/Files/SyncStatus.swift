//
//  SyncStatus.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// The status of synchronizing data from a service-based source into user's library
public struct SyncStatus: Decodable, Equatable {
    /// The details of the sources being synchronized.
    /// Not available if overall synchronization state is 'pending'.
    public let details: [SyncAccount]?
    
    /// The overall synchronization state
    public let state: SyncState
    
    enum CodingKeys: String, CodingKey {
        case details, state
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawState = try container.decode(String.self, forKey: .state)
        state = SyncState(rawValue: rawState) ?? .unknown
        
        let detailsArray = try container.decodeIfPresent(DynamicallyKeyedArray<SyncAccount>.self, forKey: .details)
        details = detailsArray?.compactMap { $0 } ?? []
    }
}
