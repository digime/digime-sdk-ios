//
//  SDKError.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Unrecoverable SDK Errors
public enum SDKError: Error {
    
    // Could not deserialize data
    case invalidData
    
    case authenticationRequired
}
