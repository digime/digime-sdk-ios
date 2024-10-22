//
//  Extensions+HKWorkoutEvent.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
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
