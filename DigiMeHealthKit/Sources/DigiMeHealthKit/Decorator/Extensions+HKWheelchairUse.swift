//
//  Extensions+HKWheelchairUse.swift
//  DigiMeSDK
//
//  Created on 27.01.21.
//

import HealthKit

extension HKWheelchairUse {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .no:
            return "No"
        case .yes:
            return "Yes"
        @unknown default:
            fatalError()
        }
    }
}
