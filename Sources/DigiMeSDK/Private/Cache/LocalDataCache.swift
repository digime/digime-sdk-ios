//
//  LocalDataCache.swift
//  DigiMeSDK
//
//  Created on 09/01/2023.
//

import Foundation

final class LocalDataCache: NSObject {
	private let userDefaults = UserDefaults.standard
	private enum Key: String, CaseIterable {
		case contracts = "kContracts"
	}
	
	func requestLocalData(for contractId: String) {
		var contracts: [String] = userDefaults.stringArray(forKey: Key.contracts.rawValue) ?? []
		contracts.append(contractId)
		userDefaults.set(contracts, forKey: Key.contracts.rawValue)
	}
	
	func removeRequestOfLocalData(for contractId: String) {
		var contracts: [String] = userDefaults.stringArray(forKey: Key.contracts.rawValue) ?? []
		contracts.remove(object: contractId)
		userDefaults.set(contracts, forKey: Key.contracts.rawValue)
	}
	
	func isDeviceDataRequested(for contractId: String) -> Bool {
		guard let contracts: [String] = userDefaults.stringArray(forKey: Key.contracts.rawValue) else {
			return false
		}
		
		return contracts.contains(contractId)
	}
	
	func reset() {
		userDefaults.removeObject(forKey: Key.contracts.rawValue)
		userDefaults.synchronize()
	}
}
