//
//  ReadOptions.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 diig.me Limited. All rights reserved.
//

import Foundation

struct ReadOptions: Encodable {
    let limits: Limits?
    let scope: Scope?
    let accept: ReadAccept?
    
    init?(accept: ReadAccept? = nil, limits: Limits? = nil, scope: Scope? = nil) {
        guard accept != nil || limits != nil || scope != nil else {
            return nil
        }
        
        self.accept = accept
        self.limits = limits
        self.scope = scope
    }
}
