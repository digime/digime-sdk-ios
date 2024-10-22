//
//  Extensions+HKCategoryValue.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKCategoryValue {
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
