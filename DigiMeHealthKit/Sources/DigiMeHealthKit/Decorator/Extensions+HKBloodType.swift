//
//  Extensions+HKBloodType.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKBloodType {
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
