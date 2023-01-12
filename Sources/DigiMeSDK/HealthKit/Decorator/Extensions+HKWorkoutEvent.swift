//
//  Extensions+HKWorkoutEvent.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import HealthKit

extension HKWorkoutEvent: Harmonizable {
    typealias Harmonized = WorkoutEvent.Harmonized

	func harmonize() throws -> Harmonized {
		return Harmonized(value: type.rawValue,
						  description: type.description,
						  metadata: metadata?.asMetadata)
	}
}
