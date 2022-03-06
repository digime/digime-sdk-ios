//
//  ReadOptions.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Options used to configure session for reading data from service-based data sources
public struct ReadOptions: Encodable {
    public let limits: Limits?
    public let scope: Scope?
    
    /// Initializes options used to configure a read session.
    /// - Parameters:
    ///   - limits: Limits for configuring a session
    ///   - scope: Custom scope used to filter data retrieval
    public init?(limits: Limits? = nil, scope: Scope? = nil) {
        guard limits != nil || scope != nil else {
            return nil
        }
        
        self.limits = limits
        self.scope = scope
    }
}
