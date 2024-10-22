//
//  Extensions+HKWorkoutRoute.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
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
