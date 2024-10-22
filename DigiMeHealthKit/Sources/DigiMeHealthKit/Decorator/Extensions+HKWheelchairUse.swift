//
//  Extensions+HKWheelchairUse.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKWheelchairUse {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .no:
            return "No"
        case .yes:
            return "Yes"
        @unknown default:
            fatalError()
        }
    }
}
