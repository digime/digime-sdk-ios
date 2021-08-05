//
//  SyncStatus.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct SyncStatus: Decodable, Equatable {
    let details: [SyncAccount] // Not available in 'pending' state
    let state: SyncState
    
    enum CodingKeys: String, CodingKey {
        case details, state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawState = try container.decode(String.self, forKey: .state)
        state = SyncState(rawValue: rawState) ?? .unknown
        
        let detailsArray = try container.decodeIfPresent(DynamicallyKeyedArray<SyncAccount>.self, forKey: .details)
        details = detailsArray?.compactMap { $0 } ?? []
    }
}
