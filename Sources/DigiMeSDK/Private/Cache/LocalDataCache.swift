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
		case deviceDataRequested = "kDeviceDataRequested"
	}
	
	@UserDefault(key: Key.deviceDataRequested, defaultValue: false)
	var deviceDataRequested: Bool
	
	func reset() {
		userDefaults.removeObject(forKey: Key.deviceDataRequested.rawValue)
		userDefaults.synchronize()
	}
}
