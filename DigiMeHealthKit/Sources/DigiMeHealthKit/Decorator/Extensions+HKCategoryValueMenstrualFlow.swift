//
//  Extensions+HKCategoryValueMenstrualFlow.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKCategoryValueMenstrualFlow {
    public var description: String {
        "HKCategoryValueMenstrualFlow"
    }
	
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .light:
            return "Light"
        case .medium:
            return "Medium"
        case .heavy:
            return "Heavy"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
}
