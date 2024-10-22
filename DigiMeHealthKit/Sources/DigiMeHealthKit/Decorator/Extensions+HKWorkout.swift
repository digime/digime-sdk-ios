//
//  Extensions+HKWorkout.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKWorkout: Harmonizable {
    typealias Harmonized = Workout.Harmonized

	func harmonize() throws -> Harmonized {
		let totalEnergyBurnedUnit = HKUnit.largeCalorie()
		let totalEnergyBurned = self.totalEnergyBurned?.doubleValue(for: totalEnergyBurnedUnit)
		
		let totalDistanceUnit = HKUnit.meter()
		let totalDistance = self.totalDistance?.doubleValue(for: totalDistanceUnit)
		
		let countUnit = HKUnit.count()
		let totalSwimmingStrokeCount = self.totalSwimmingStrokeCount?.doubleValue(for: countUnit)
		let totalFlightsClimbed = self.totalFlightsClimbed?.doubleValue(for: countUnit)
		
		return Harmonized(value: Int(workoutActivityType.rawValue),
						  description: workoutActivityType.description,
						  totalEnergyBurned: totalEnergyBurned,
						  totalEnergyBurnedUnit: totalEnergyBurnedUnit.unitString,
						  totalDistance: totalDistance,
						  totalDistanceUnit: totalDistanceUnit.unitString,
						  totalSwimmingStrokeCount: totalSwimmingStrokeCount,
						  totalSwimmingStrokeCountUnit: countUnit.unitString,
						  totalFlightsClimbed: totalFlightsClimbed,
						  totalFlightsClimbedUnit: countUnit.unitString,
						  metadata: metadata?.asMetadata)
	}
}
