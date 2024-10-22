//
//  Extensions+HKCategoryValueProgesteroneTestResult.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 15.0, *)
extension HKCategoryValueProgesteroneTestResult {
    public var description: String {
        "HKCategoryValueProgesteroneTestResult"
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
