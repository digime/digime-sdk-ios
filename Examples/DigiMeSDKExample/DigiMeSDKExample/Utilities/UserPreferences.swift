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
		case accounts = "kAccounts"
		case services = "kServices"
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
	
	// MARK: - Accounts
		
	@CodableUserDefault(key: Key.accounts)
	private var accounts: [String: [SourceAccount]]?
	
	func accounts(for contractId: String) -> [SourceAccount]? {
		return accounts?[contractId]
	}
	
	func setAccounts(newAccounts: [SourceAccount], for contractId: String) {
		var cachedAccounts = accounts ?? [:]
		cachedAccounts[contractId] = newAccounts
		accounts = cachedAccounts
	}
	
	func clearAccounts(for contractId: String) {
		accounts?[contractId] = nil
	}
	
	// MARK: - Services
		
	@CodableUserDefault(key: Key.services)
	private var services: [String: [Service]]?
	
	func services(for contractId: String) -> [Service] {
		return services?[contractId] ?? []
	}
	
	func setServices(newServices: [Service], for contractId: String) {
		var cachedServices = services ?? [:]
		cachedServices[contractId] = newServices
		services = cachedServices
	}
	
	func addService(newService: Service, for contractId: String) {
		var cachedServicesDictionary = services ?? [:]
		cachedServicesDictionary[contractId]?.append(newService)
		services = cachedServicesDictionary
	}
	
	func clearServices(for contractId: String) {
		services?[contractId] = nil
	}
	
	func reset() {
		credentials = nil
		accounts = nil
		services = nil
	}
}
