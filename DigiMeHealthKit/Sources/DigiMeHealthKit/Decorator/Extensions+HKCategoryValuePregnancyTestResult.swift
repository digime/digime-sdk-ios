//
//  Extensions+HKCategoryValuePregnancyTestResult.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 15.0, *)
extension HKCategoryValuePregnancyTestResult {
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
