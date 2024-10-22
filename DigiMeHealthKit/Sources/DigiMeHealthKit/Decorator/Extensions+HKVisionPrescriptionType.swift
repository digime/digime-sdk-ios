//
//  Extensions+HKVisionPrescriptionType.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 16.0, *)
extension HKVisionPrescriptionType {
    public var description: String {
        "HKVisionPrescriptionType"
    }
	
    public var detail: String {
        switch self {
        case .glasses:
            return "Glasses"
        case .contacts:
            return "Contacts"
        @unknown default:
            return "Unknown"
        }
    }
}
