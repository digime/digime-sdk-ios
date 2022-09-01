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
	private let domain: String
	private let keyPrefix: String
    
	/// Initializes an instance of session cache
	init() {
		domain = "me.digi.sdk.session"
		keyPrefix = "\(domain)."
	}
	
    func session(for contractId: String) -> Session? {
        guard let results = userDefaults.data(forKey: key(for: contractId)) else {
            return nil
        }
        
        return try? results.decoded() as Session
    }
    
    func setSession(_ session: Session?, for contractId: String) {
		guard
			let session = session,
			let data = try? session.encoded() else {
			
			clearSession(for: contractId)
			return
		}

        userDefaults.set(data, forKey: key(for: contractId))
		Logger.info("Session: \(session) for contract id: \(contractId)")
    }
    
	func clearSession(for contractId: String) {
		userDefaults.set(nil, forKey: key(for: contractId))
	}
	
    private func key(for contractId: String) -> String {
        keyPrefix + contractId
    }
}
