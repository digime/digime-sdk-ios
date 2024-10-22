//
//  Extensions+HKCategoryValueAppetiteChanges.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 13.6, *)
extension HKCategoryValueAppetiteChanges {
    public var description: String {
        "HKCategoryValueAppetiteChanges"
    }
	
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .noChange:
            return "No Change"
        case .decreased:
            return "Decreased"
        case .increased:
            return "Increased"
        @unknown default:
            return "Unknown"
        }
    }
}
