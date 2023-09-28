//
//  Extensions+HKCategoryValueCervicalMucusQuality.swift
//  DigiMeSDK
//
//  Created on 05.09.21.
//

import HealthKit

extension HKCategoryValueCervicalMucusQuality: CustomStringConvertible {
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
