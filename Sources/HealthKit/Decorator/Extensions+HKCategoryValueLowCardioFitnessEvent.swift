//
//  Extensions+HKCategoryValueLowCardioFitnessEvent.swift
//  DigiMeSDK
//
//  Created on 05.09.21.
//

import HealthKit

@available(iOS 14.3, *)
extension HKCategoryValueLowCardioFitnessEvent: CustomStringConvertible {
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
