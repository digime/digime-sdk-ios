//
//  Extensions+HKFitzpatrickSkinType.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKFitzpatrickSkinType {
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .I:
            return "I"
        case .II:
            return "II"
        case .III:
            return "III"
        case .IV:
            return "IV"
        case .V:
            return "V"
        case .VI:
            return "VI"
        @unknown default:
            fatalError()
        }
    }
}
