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
		case connectedAccounts = "kConnectedAccounts"
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
	private var credentials: [String: Credentials]?
	
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
	
	// MARK: - Connected Accounts
		
	@CodableUserDefault(key: Key.connectedAccounts)
	private var connectedAccounts: [String: [ConnectedAccount]]?
	
	func connectedAccounts(for contractId: String) -> [ConnectedAccount] {
		return connectedAccounts?[contractId] ?? []
	}
	
	func setConnectedAccounts(newAccounts: [ConnectedAccount], for contractId: String) {
		var cached = connectedAccounts ?? [:]
		cached[contractId] = newAccounts
		connectedAccounts = cached
	}
	
	func addConnectedAccount(newAccount: ConnectedAccount, for contractId: String) {
		var cached = connectedAccounts ?? [:]
		cached[contractId]?.append(newAccount)
		connectedAccounts = cached
	}
	
	func clearConnectedAccounts(for contractId: String) {
		connectedAccounts?[contractId] = nil
	}
	
	func reset() {
		credentials = nil
		connectedAccounts = nil
	}
}
