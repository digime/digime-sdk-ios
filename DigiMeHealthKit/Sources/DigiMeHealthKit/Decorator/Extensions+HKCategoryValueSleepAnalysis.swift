//
//  Extensions+HKCategoryValueSleepAnalysis.swift
//  DigiMeSDK
//
//  Created on 05.09.21.
//

import HealthKit

extension HKCategoryValueSleepAnalysis: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueSleepAnalysis"
    }
	
    public var detail: String {
        switch self {
        case .inBed:
            return "In Bed"
        case .asleepUnspecified:
            return "Asleep unspecified"
        case .awake:
            return "Awake"
        case .asleepCore:
            return "Asleep core"
        case .asleepDeep:
            return "Asleep deep"
        case .asleepREM:
            return "Asleep REM"
        @unknown default:
            return "Unknown"
        }
    }
}
