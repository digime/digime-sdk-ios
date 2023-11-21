//
//  Extensions+HKBloodType.swift
//  DigiMeSDK
//
//  Created on 15.09.20.
//

import HealthKit

extension HKBloodType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        @unknown default:
            fatalError()
        }
    }
}
