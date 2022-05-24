//
//  SessionCache.swift
//  DigiMeSDK
//
//  Created on 22/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

final class SessionCache {
    private let userDefaults = UserDefaults.standard
    private let keyPrefix = "me.digi.sdk.session."
    
    func session(for contractId: String) -> Session? {
        guard let results = userDefaults.data(forKey: key(for: contractId)) else {
            return nil
        }
        
        return try? results.decoded() as Session
    }
    
    func setSession(_ session: Session?, for contractId: String) {
        let data = try? session?.encoded()
        userDefaults.set(data, forKey: key(for: contractId))
    }
    
	func clearSession(for contractId: String) {
		userDefaults.set(nil, forKey: key(for: contractId))
	}
	
    private func key(for contractId: String) -> String {
        keyPrefix + contractId
    }
}
