//
//  Extensions+HKCategoryValueAppleWalkingSteadinessEvent.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 15.0, *)
extension HKCategoryValueAppleWalkingSteadinessEvent {
    public var description: String {
        "HKCategoryValueAppleWalkingSteadinessEvent"
    }
	
    public var detail: String {
        switch self {
        case .initialLow:
            return "Initial low"
        case .initialVeryLow:
            return "Initial very low"
        case .repeatLow:
            return "Repeat low"
        case .repeatVeryLow:
            return "Repeat very low"
        @unknown default:
            return "Unknown"
        }
    }
}
