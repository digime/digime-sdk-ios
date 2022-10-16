//
//  CaloriesFormatter.swift
//  DigiMeSDKExample
//
//  Created on 16/10/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

class CaloriesFormatter: NSObject {
    class func stringForCaloriesValue(_ calories: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.locale = Locale(identifier: "en_UK")
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter.string(from: Measurement(value: calories, unit: UnitEnergy.calories))
    }
}
