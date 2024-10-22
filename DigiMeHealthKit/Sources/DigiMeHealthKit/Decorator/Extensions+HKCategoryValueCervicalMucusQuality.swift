//
//  Extensions+HKCategoryValueCervicalMucusQuality.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKCategoryValueCervicalMucusQuality {
    public var description: String {
        "HKCategoryValueCervicalMucusQuality"
    }
	
    public var detail: String {
        switch self {
        case .dry:
            return "Dry"
        case .sticky:
            return "Sticky"
        case .creamy:
            return "Creamy"
        case .watery:
            return "Watery"
        case .eggWhite:
            return "Egg White"
        @unknown default:
            return "Unknown"
        }
    }
}
