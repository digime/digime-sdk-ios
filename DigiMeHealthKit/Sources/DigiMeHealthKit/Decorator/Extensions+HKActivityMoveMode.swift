//
//  Extensions+HKActivityMoveMode.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 14.0, *)
extension HKActivityMoveMode {
    public var description: String {
        switch self {
        case .activeEnergy:
            return "Active energy"
        case .appleMoveTime:
            return "Apple move time"
        @unknown default:
            fatalError()
        }
    }
}
