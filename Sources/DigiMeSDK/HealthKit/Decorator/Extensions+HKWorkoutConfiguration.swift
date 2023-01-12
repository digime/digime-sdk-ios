//
//  Extensions+HKWorkoutConfiguration.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import HealthKit

extension HKWorkoutConfiguration: Harmonizable {
    typealias Harmonized = WorkoutConfiguration.Harmonized

    func harmonize() throws -> Harmonized {
        let unit = HKUnit.meter()
        guard let value = lapLength?.doubleValue(for: unit) else {
			throw SDKError.invalidValue(message: "Value for HKWorkoutConfiguration is invalid")
        }
		
        return Harmonized(value: value, unit: unit.unitString)
    }
}
