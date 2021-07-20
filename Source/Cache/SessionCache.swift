//
//  SessionCache.swift
//  DigiMeSDK
//
//  Created on 22/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class SessionCache: Caching {
    private let userDefaults = UserDefaults.standard
    private let key = "me.digi.sdk.session"
    
    var contents: Session? {
        get {
            guard let results = userDefaults.data(forKey: key) else {
                return nil
            }
            
            return try? results.decoded() as Session
        }
        
        set {
            let data = try? newValue?.encoded()
            userDefaults.set(data, forKey: key)
        }
    }
    
    var lastUpdate = Date.distantPast
}
