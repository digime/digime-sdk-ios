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
        case storageId = "kStorageId"
        case readOptions = "kReadOptions"
        case activeContract = "kActiveContract"
	}
	
	@discardableResult
	class func shared() -> UserPreferences {
		return sharedPreferences
	}
	
	private static var sharedPreferences: UserPreferences = {
		return UserPreferences()
	}()

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

    // MARK: - Reset

	func reset() {
        activeContract = nil
        storageIds = nil
        readOptions = nil
	}
}
