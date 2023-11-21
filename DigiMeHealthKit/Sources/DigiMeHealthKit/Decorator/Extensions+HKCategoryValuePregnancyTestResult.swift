//
//  Extensions+HKCategoryValuePregnancyTestResult.swift
//  DigiMeSDK
//
//  Created on 04.10.22.
//

import HealthKit

@available(iOS 15.0, *)
extension HKCategoryValuePregnancyTestResult: CustomStringConvertible {
    public var description: String {
        "HKCategoryValuePregnancyTestResult"
    }
	
    public var detail: String {
        switch self {
        case .negative:
            return "Negative"
        case .positive:
            return "Positive"
        case .indeterminate:
            return "Indeterminate"
        @unknown default:
            return "Unknown"
        }
    }
}
