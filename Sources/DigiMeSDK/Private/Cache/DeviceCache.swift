//
//  DeviceCache.swift
//  DigiMeSDK
//
//  Created on 09/01/2023.
//

import Foundation

final class DeviceCache: NSObject {
	private let userDefaults = UserDefaults.standard
	private enum Key: String, CaseIterable {
		case deviceDataRequested = "kDeviceDataRequested"
	}
	
	@discardableResult
	class func shared() -> DeviceCache {
		return sharedPreferences
	}
	
	private static var sharedPreferences: DeviceCache = {
		return DeviceCache()
	}()
	
	@UserDefault(key: Key.deviceDataRequested, defaultValue: false)
	var deviceDataRequested: Bool
}
