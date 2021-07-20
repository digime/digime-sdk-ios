//
//  ReadOptions.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct ReadOptions: Encodable {
    let limits: Limits?
    let scope: Scope?
    
    public init?(limits: Limits? = nil, scope: Scope? = nil) {
        guard limits != nil || scope != nil else {
            return nil
        }
        
        self.limits = limits
        self.scope = scope
    }
}
