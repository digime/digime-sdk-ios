//
//  Extensions+HKCategoryValueOvulationTestResult.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKCategoryValueOvulationTestResult {
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
