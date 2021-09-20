//
//  SyncState.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// State of synchronization
/// - `running`: Currently importing data from source into user's library
/// - `pending`: Connecting to source
/// - `partial`: Synchronization partially complete, usuallyy due to errors connecting to source or errors importing data to user's library.
/// - `completed`: Importing data from source into user's library has finished
/// - `unknown`: Special case to handle forward compatibility in case as new/unexpected state is encountered. Treated same as `running` state.
public enum SyncState: String, Decodable, Equatable {
    case running
    case pending
    case partial
    case completed
    
    case unknown
    
    /// Whether synchronization is in progress or finished
    public var isRunning: Bool {
        switch self {
        case .running, .pending, .unknown:
            return true
        case .partial, .completed:
            return false
        }
    }
}
