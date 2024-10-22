//
//  Extensions+HKWorkoutConfiguration.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation
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
