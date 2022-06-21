//
//  ContractsCache.swift
//  DigiMeSDK
//
//  Created on 20/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

final class ContractsCache: NSObject {
	
	@CodableUserDefault(key: Key.cachedItems)
	private var timeRanges: [String: [ConsentAccessTimeRange]]?
	private let userDefaults = UserDefaults.standard
	private enum Key: String, CaseIterable {
		case cachedItems = "kCacheItems"
	}
	
	// MARK: - Time Ranges

	func timeRanges(for contractId: String) -> [ConsentAccessTimeRange]? {
		let cachedItems = timeRanges ?? [:]
		guard let ranges = cachedItems[contractId] else {
			return nil
		}
		
		return ranges
	}
	
	func firstTimeRange(for contractId: String) -> ConsentAccessTimeRange? {
		guard let range = timeRanges(for: contractId)?.first else {
			return nil
		}
		
		return range
	}
		
	func addTimeRanges(ranges: [ConsentAccessTimeRange]?, for contractId: String) {
		guard let ranges = ranges else {
			return
		}
		
		var cachedItems = timeRanges ?? [:]
		cachedItems[contractId] = ranges
		timeRanges = cachedItems
	}
	
	func deleteTimeRanges(for contractIds: Set<String>) {
		var cachedItems = timeRanges ?? [:]
		cachedItems = cachedItems.filter { !contractIds.contains($0.0) }
		timeRanges = cachedItems
	}
	
	func clearTimeRanges(for contractId: String) {
		var cachedItems = timeRanges ?? [:]
		cachedItems.removeValue(forKey: contractId)
		timeRanges = cachedItems
	}
	
	// MARK: - Common
	
	func reset() {
		timeRanges = nil
	}
}
