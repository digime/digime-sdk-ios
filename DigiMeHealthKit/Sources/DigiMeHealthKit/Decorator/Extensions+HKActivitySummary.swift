//
//  Extensions+HKActivitySummary.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKActivitySummary: Harmonizable {
    typealias Harmonized = ActivitySummary.Harmonized

	func harmonize() throws -> Harmonized {
		let activeEnergyBurnedUnit = HKUnit.largeCalorie()
		let activeEnergyBurned = self.activeEnergyBurned.doubleValue(for: activeEnergyBurnedUnit)
		let activeEnergyBurnedGoal = self.activeEnergyBurnedGoal.doubleValue(for: activeEnergyBurnedUnit)
		let appleExerciseTimeUnit = HKUnit.minute()
		let appleExerciseTime = self.appleExerciseTime.doubleValue(for: appleExerciseTimeUnit)
		let appleExerciseTimeGoal = self.appleExerciseTimeGoal.doubleValue(for: appleExerciseTimeUnit)
		let appleStandHoursUnit = HKUnit.count()
		let appleStandHours = self.appleStandHours.doubleValue(for: appleStandHoursUnit)
		let appleStandHoursGoal = self.appleStandHoursGoal.doubleValue(for: appleStandHoursUnit)
		return Harmonized(activeEnergyBurned: activeEnergyBurned,
						  activeEnergyBurnedGoal: activeEnergyBurnedGoal,
						  activeEnergyBurnedUnit: activeEnergyBurnedUnit.unitString,
						  appleExerciseTime: appleExerciseTime,
						  appleExerciseTimeGoal: appleExerciseTimeGoal,
						  appleExerciseTimeUnit: appleExerciseTimeUnit.unitString,
						  appleStandHours: appleStandHours,
						  appleStandHoursGoal: appleStandHoursGoal,
						  appleStandHoursUnit: appleStandHoursUnit.unitString)
	}
}
