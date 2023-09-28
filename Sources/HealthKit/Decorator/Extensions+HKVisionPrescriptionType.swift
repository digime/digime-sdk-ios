//
//  Extensions+HKVisionPrescriptionType.swift
//  DigiMeSDK
//
//  Created on 04.10.22.
//

import HealthKit

@available(iOS 16.0, *)
extension HKVisionPrescriptionType: CustomStringConvertible {
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
