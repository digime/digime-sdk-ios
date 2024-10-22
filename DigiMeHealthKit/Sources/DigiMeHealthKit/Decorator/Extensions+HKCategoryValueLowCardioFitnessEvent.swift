//
//  Extensions+HKCategoryValueLowCardioFitnessEvent.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 14.3, *)
extension HKCategoryValueLowCardioFitnessEvent {
    public var description: String {
        String(describing: self)
    }
	
    public var detail: String {
        switch self {
        case .lowFitness:
            return "Low Fitness"
        @unknown default:
            return "Unknown"
        }
    }
}
