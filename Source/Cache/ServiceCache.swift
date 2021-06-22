//
//  ServiceCache.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class ServiceCache: Caching {
    private let userDefaults = UserDefaults.standard
    private let key = "services"
    
    var contents: [Service]? {
        get {
            guard let results = userDefaults.data(forKey: key) else {
                return nil
            }
            
            return try? results.decoded() as [Service]
        }
        
        set {
            let data = try? newValue?.encoded()
            userDefaults.set(data, forKey: key)
        }
    }
    
    var lastUpdate = Date.distantPast
}
