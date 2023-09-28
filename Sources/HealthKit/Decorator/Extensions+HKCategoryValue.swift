//
//  Extensions+HKCategoryValue.swift
//  DigiMeSDK
//
//  Created on 05.09.21.
//

import HealthKit

extension HKCategoryValue: CustomStringConvertible {
    public var description: String {
        "HKCategoryValue"
    }
	
    public var detail: String {
        switch self {
        case .notApplicable:
            return "Not Applicable"
        @unknown default:
            return "Unknown"
        }
    }
}
