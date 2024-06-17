//
//  UserPreferences.swift
//  DigiMeSDKExample
//
//  Created on 20/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import Foundation

final class UserPreferences: NSObject {
	
	private let userDefaults = UserDefaults.standard
	private enum Key: String, CaseIterable {
		case credentials = "kCredentials"
		case connectedAccounts = "kConnectedAccounts"
        case storageId = "kStorageId"
        case readOptions = "kReadOptions"
        case selfMeasurementLastUsedType = "kSelfMeasurementLastUsedType"
        case selfMeasurementPersonId = "kSelfMeasurementPersonId"
        case activeContract = "kActiveContract"
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
	
	func getCredentials(for contractId: String) -> Credentials? {
		return credentials?[contractId]
	}
	
	func setCredentials(newCredentials: Credentials, for contractId: String?) {
        guard let contractId = contractId else {
            return
        }
        
		var cachedCredentials = credentials ?? [:]
		cachedCredentials[contractId] = newCredentials
		credentials = cachedCredentials
	}
	
	func clearCredentials(for contractId: String?) {
        guard let contractId = contractId else {
            return
        }

		credentials?[contractId] = nil
	}
	
	// MARK: - Onboarded Accounts

	@CodableUserDefault(key: Key.connectedAccounts)
	private var linkedAccounts: [String: [LinkedAccount]]?
	
	func getLinkedAccounts(for contractId: String) -> [LinkedAccount] {
		return linkedAccounts?[contractId] ?? []
	}
	
	func setLinkedAccounts(newAccounts: [LinkedAccount], for contractId: String) {
		var cached = linkedAccounts ?? [:]
		cached[contractId] = newAccounts
		linkedAccounts = cached
	}
	
	func addLinkedAccount(newAccount: LinkedAccount, for contractId: String) {
		var cached = linkedAccounts ?? [:]
		cached[contractId]?.append(newAccount)
		linkedAccounts = cached
	}
	
	func clearLinkedAccounts(for contractId: String) {
		linkedAccounts?[contractId] = nil
	}
    
    func refreshLinkedAccount(for connectedAccountId: UUID, objectTypeId: Int, selected: Bool, contractId: String) {
        if
            let index = getLinkedAccounts(for: contractId).firstIndex(where: { $0.id == connectedAccountId }),
            var linkedAccount = linkedAccounts?[contractId]?[index] {

            if selected {
                linkedAccount.selectedObjectTypeIds.insert(objectTypeId)
            }
            else {
                linkedAccount.selectedObjectTypeIds.remove(objectTypeId)
            }

            linkedAccounts?[contractId]?[index] = linkedAccount
        }
    }

    // MARK: - Active Contract

    @CodableUserDefault(key: Key.activeContract)
    var activeContract: DigimeContract?

    // MARK: - Storage

    @CodableUserDefault(key: Key.storageId)
    private var storageIds: [String: String]?

    func getStorageId(for contractId: String) -> String? {
        return storageIds?[contractId]
    }

    func setStorageId(identifier: String, for contractId: String) {
        var cached = storageIds ?? [:]
        cached[contractId] = identifier
        storageIds = cached
    }

    func clearStorageIds(for contractId: String) {
        storageIds?[contractId] = nil
    }

    // MARK: - Read Options
    
    @CodableUserDefault(key: Key.readOptions)
    private var readOptions: [String: ReadOptions]?
    
    func readOptions(for contractId: String) -> ReadOptions? {
        return readOptions?[contractId]
    }
    
    func setReadOptions(newReadOptions: ReadOptions?, for contractId: String) {
        var cached = readOptions ?? [:]
        cached[contractId] = newReadOptions
        readOptions = cached
    }
    
    func clearReadOptions(for contractId: String) {
        readOptions?[contractId] = nil
    }

    // MARK: Self Measurements

    @UserDefault(key: Key.selfMeasurementLastUsedType, defaultValue: SelfMeasurementType.weight.rawValue)
    var selfMeasurementLastUsedType: Int

    @UserDefault(key: Key.selfMeasurementPersonId, defaultValue: UUID().uuidString, persistDefaultValue: true)
    var selfMeasurementPersonId: String

    // MARK: - Reset

	func reset() {
		credentials = nil
		linkedAccounts = nil
        storageIds = nil
        readOptions = nil
        activeContract = nil
	}
}
