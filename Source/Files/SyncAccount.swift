//
//  SyncAccount.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Details of a source being synchronized
public struct SyncAccount: Decodable, Equatable {
    /// The service's account's identifier
    /// Only available for service-based sources, not for data written by this or another contract.
    public let identifier: String?
    
    /// The synchronization state for this source
    public let state: SyncState
    
    /// An error giving details of the reason synchronization failed.
    /// Only available for 'partial' synchronization state
    public let error: SyncError?
    
    enum CodingKeys: String, CodingKey {
        case state, error
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode name
        let rawState = try container.decode(String.self, forKey: .state)
        state = SyncState(rawValue: rawState) ?? .unknown
        
        error = try container.decodeIfPresent(SyncError.self, forKey: .error)
        
        // Extract identifier from coding path
        identifier = container.codingPath.first!.stringValue
    }
}
