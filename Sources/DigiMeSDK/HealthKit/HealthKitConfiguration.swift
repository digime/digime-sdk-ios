//
//  HealthKitConfiguration.swift
//  DigiMeSDK
//
//  Created on 27/12/2022.
//

import Foundation

public struct HealthKitConfiguration {
	public let typesToRead: [ObjectType]
	public let typesToWrite: [QuantityType]
	public let startDate: Date
	public let endDate: Date
	public let anchorDate: Date?
	public let mergeResultForSameType: Bool
	public let singleCallbackForAllTypes: Bool
	public let intervalComponents: DateComponents?
	
	public init(typesToRead: [ObjectType], typesToWrite: [QuantityType], startDate: Date, endDate: Date, anchorDate: Date?, mergeResultForSameType: Bool, singleCallbackForAllTypes: Bool, intervalComponents: DateComponents?) {
		self.typesToRead = typesToRead
		self.typesToWrite = typesToWrite
		self.startDate = startDate
		self.endDate = endDate
		self.anchorDate = anchorDate
		self.mergeResultForSameType = mergeResultForSameType
		self.singleCallbackForAllTypes = singleCallbackForAllTypes
		self.intervalComponents = intervalComponents
	}
}
