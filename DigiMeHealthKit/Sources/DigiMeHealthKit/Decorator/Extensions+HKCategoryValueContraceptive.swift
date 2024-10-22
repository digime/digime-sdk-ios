//
//  Extensions+HKCategoryValueContraceptive.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 14.3, *)
extension HKCategoryValueContraceptive {
    public var description: String {
        "HKCategoryValueContraceptive"
    }
	
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .implant:
            return "Implant"
        case .injection:
            return "Injection"
        case .intrauterineDevice:
            return "Intrauterine Device"
        case .intravaginalRing:
            return "Intravaginal Ring"
        case .oral:
            return "Oral"
        case .patch:
            return "Patch"
        @unknown default:
            return "Unknown"
        }
    }
}
