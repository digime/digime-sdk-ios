//
//  SyncAccount.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct SyncAccount: Decodable, Equatable {
    let identifier: String? // Not available for written data
    let state: SyncState
    let error: SyncError? // Only available for 'partial' state
    
    enum CodingKeys: String, CodingKey {
        case state, error
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode name
        let rawState = try container.decode(String.self, forKey: .state)
        state = SyncState(rawValue: rawState) ?? .unknown
        
        error = try container.decodeIfPresent(SyncError.self, forKey: .error)
        
        // Extract identifier from coding path
        identifier = container.codingPath.first!.stringValue
    }
}
