//
//  Extensions+HKCategoryValueSeverity.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 13.6, *)
extension HKCategoryValueSeverity {
    public var description: String {
        "HKCategoryValueSeverity"
    }
	
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .notPresent:
            return "Not Present"
        case .mild:
            return "Mild"
        case .moderate:
            return "Moderate"
        case .severe:
            return "Severe"
        @unknown default:
            return "Unknown"
        }
    }
}
