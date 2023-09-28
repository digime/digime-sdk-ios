//
//  Extensions+HKWorkoutRoute.swift
//  DigiMeSDK
//
//  Created on 16.04.22.
//

import HealthKit

extension HKWorkoutRoute {
    typealias Harmonized = WorkoutRoute.Harmonized

	func harmonize(routes: [WorkoutRoute.Route]) -> Harmonized {
		Harmonized(count: count,
				   routes: routes,
				   metadata: metadata?.asMetadata)
	}
}
