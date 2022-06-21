//
//  UserPreferences.swift
//  DigiMeSDKExample
//
//  Created on 20/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

final class UserPreferences: NSObject {
	
	private let userDefaults = UserDefaults.standard
	private enum Key: String, CaseIterable {
		case credentials = "kCredentials"
	}
	
	@discardableResult
	class func shared() -> UserPreferences {
		return sharedPreferences
	}
	
	private static var sharedPreferences: UserPreferences = {
		return UserPreferences()
	}()
	
	// MARK: - Credentials
	
	@CodableUserDefault(key: Key.credentials)
	private var credentials: [String: Credentials]? {
		didSet {
			if let cred = credentials {
				debugPrint("CREDENTIALS: \(cred as Any)")
			}
		}
	}
	
	func credentials(for contractId: String) -> Credentials? {
		return credentials?[contractId]
	}
	
	func setCredentials(newCredentials: Credentials, for contractId: String) {
		var cachedCredentials = credentials ?? [:]
		cachedCredentials[contractId] = newCredentials
		credentials = cachedCredentials
	}
	
	func clearCredentials(for contractId: String) {
		credentials?[contractId] = nil
	}
	
	func reset() {
		credentials = nil
	}
}
