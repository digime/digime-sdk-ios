//
//  SyncState.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public enum SyncState: String, Decodable, Equatable {
    case running
    case pending
    case partial
    case completed
    
    case unknown
    
    public var isRunning: Bool {
        switch self {
        case .running, .pending, .unknown:
            return true
        case .partial, .completed:
            return false
        }
    }
}
