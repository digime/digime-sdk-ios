//
//  Extensions+HKSample.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import HealthKit

extension HKSample {
    func parsed() throws -> Sample {
        if let quantitiy = self as? HKQuantitySample {
            return try Quantity(quantitySample: quantitiy)
        }
        if let category = self as? HKCategorySample {
            return try Category(categorySample: category)
        }
        if let workout = self as? HKWorkout {
            return try Workout(workout: workout)
        }
        if let correlation = self as? HKCorrelation {
            return try Correlation(correlation: correlation)
        }
        if #available(iOS 14.0, *) {
            if let electrocardiogram = self as? HKElectrocardiogram {
                return try Electrocardiogram(electrocardiogram: electrocardiogram, voltageMeasurements: [])
            }
        }
		throw SDKError.parsingFailed(message: "HKSample could not be parsed")
    }
}
