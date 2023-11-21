//
//  Extensions+HKCategoryValueOvulationTestResult.swift
//  DigiMeSDK
//
//  Created on 05.09.21.
//

import HealthKit

extension HKCategoryValueOvulationTestResult: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueOvulationTestResult"
    }
	
    public var detail: String {
        switch self {
        case .negative:
            return "Negative"
        case .luteinizingHormoneSurge:
            return "Luteinizing Hormone Surge"
        case .indeterminate:
            return "Indeterminate"
        case .estrogenSurge:
            return "Estrogen Surge"
        @unknown default:
            return "Unknown"
        }
    }
}
