//
//  Statistics.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import HealthKit

public struct Statistics: PayloadIdentifiable, Sample {
	public var uid = UUID()
	public let identifier: String
	public let startTimestamp: Double
	public let endTimestamp: Double
	public var harmonized: Harmonized
	public var sources: [Source]

	init(statistics: HKStatistics, unit: HKUnit) throws {
		self.identifier = statistics.quantityType.identifier
		self.startTimestamp = statistics.startDate.timeIntervalSince1970
		self.endTimestamp = statistics.endDate.timeIntervalSince1970
		self.sources = statistics.sources?.map { Source(source: $0) } ?? []
		self.harmonized = Harmonized(summary: statistics.sumQuantity()?.doubleValue(for: unit),
									 average: statistics.averageQuantity()?.doubleValue(for: unit),
									 recent: statistics.mostRecentQuantity()?.doubleValue(for: unit),
									 min: statistics.minimumQuantity()?.doubleValue(for: unit),
									 max: statistics.maximumQuantity()?.doubleValue(for: unit),
									 unit: unit.unitString)
	}
	
	init(statistics: HKStatistics) throws {
		self.identifier = statistics.quantityType.identifier
		self.startTimestamp = statistics.startDate.timeIntervalSince1970
		self.endTimestamp = statistics.endDate.timeIntervalSince1970
		self.sources = statistics.sources?.map { Source(source: $0) } ?? []
		self.harmonized = try statistics.harmonize()
	}
	
	private init(identifier: String, startTimestamp: Double, endTimestamp: Double, harmonized: Harmonized, sources: [Source]) {
		self.identifier = identifier
		self.startTimestamp = startTimestamp
		self.endTimestamp = endTimestamp
		self.harmonized = harmonized
		self.sources = sources
	}
	
	public func copyWith(identifier: String? = nil, startTimestamp: Double? = nil, endTimestamp: Double? = nil, harmonized: Harmonized? = nil, sources: [Source]? = nil) -> Statistics {
		
		return Statistics(identifier: identifier ?? self.identifier,
						  startTimestamp: startTimestamp ?? self.startTimestamp,
						  endTimestamp: endTimestamp ?? self.endTimestamp,
						  harmonized: harmonized ?? self.harmonized,
						  sources: sources ?? self.sources)
	}
	
	func merge(obj1: Statistics, obj2: Statistics) throws -> Statistics {
		guard obj1.identifier == obj2.identifier else {
			throw SDKError.invalidValue(message: "Invalid identifier when merge: \(obj2.identifier)")
		}

		let startTimestamp = min(obj1.startTimestamp, obj2.startTimestamp)
		let endTimestamp = max(obj1.endTimestamp, obj2.endTimestamp)
		let harmonized = try obj1.harmonized.mergeValues(of: obj1.harmonized, with: obj2.harmonized)
		let sources = mergeSources(array1: obj1.sources, array2: obj2.sources)
		
		return Statistics(identifier: obj1.identifier, startTimestamp: startTimestamp, endTimestamp: endTimestamp, harmonized: harmonized, sources: sources)
	}
	
	private func mergeSources(array1: [Source], array2: [Source]) -> [Source] {
		return Array(Set(array1).union(Set(array2)))
	}
	
	// MARK: - Harmonized
	
	public struct Harmonized: Codable {
		public var summary: Double?
		public var average: Double?
		public var recent: Double?
		public var min: Double?
		public var max: Double?
		public let unit: String

		public init(summary: Double? = nil, average: Double? = nil, recent: Double? = nil, min: Double? = nil, max: Double? = nil, unit: String) {
			self.summary = summary
			self.average = average
			self.recent = recent
			self.min = min
			self.max = max
			self.unit = unit
		}

		public func copyWith(summary: Double? = nil, average: Double? = nil, recent: Double? = nil, min: Double? = nil, max: Double? = nil, unit: String? = nil) -> Harmonized {
			
			return Harmonized(summary: summary ?? self.summary,
							  average: average ?? self.average,
							  recent: recent ?? self.recent,
							  min: min ?? self.min,
							  max: max ?? self.max,
							  unit: unit ?? self.unit)
		}
		
		public func mergeValues(of obj1: Harmonized, with obj2: Harmonized) throws -> Harmonized {
			guard obj1.unit == obj2.unit else {
				throw SDKError.invalidValue(message: "Error merging Harmonized objects.")
			}
			
			let summary = mergeValuesIfPresent(val1: obj1.summary, val2: obj2.summary)
			let average = mergeValuesIfPresent(val1: obj1.average, val2: obj2.average)
			let recent = mergeValuesIfPresent(val1: obj1.recent, val2: obj2.recent)
			let min = mergeValuesIfPresent(val1: obj1.min, val2: obj2.min)
			let max = mergeValuesIfPresent(val1: obj1.max, val2: obj2.max)
			return Harmonized(summary: summary, average: average, recent: recent, min: min, max: max, unit: obj1.unit)
		}
		
		private func mergeValuesIfPresent(val1: Double? , val2: Double?) -> Double? {
			guard
				let val1 = val1,
				let val2 = val2 else {
				
				return val1 ?? val2
			}
			
			return val1 + val2
		}
	}
}

// MARK: - UnitConvertable
extension Statistics: UnitConvertable {
	public func converted(to unit: String) throws -> Statistics {
		guard harmonized.unit != unit else {
			return self
		}
		
		return copyWith(harmonized: harmonized.copyWith(unit: unit))
	}
}
