//
//  HealthDataSupport.swift
//  DigiMeSDK
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import HealthKit

// MARK: Sample Type Identifier Support

public extension HKSampleType {
    static func getSampleType(for identifier: String) -> HKSampleType? {
        if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
            return quantityType
        }
        
        if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
            return categoryType
        }
        
        return nil
    }
}

// MARK: - Unit Support

public extension HKUnit {
    static func preferredUnit(for sample: HKSample) -> HKUnit? {
        let unit = preferredUnit(for: sample.sampleType.identifier, sampleType: sample.sampleType)
        
        if let quantitySample = sample as? HKQuantitySample, let unit = unit {
            assert(quantitySample.quantity.is(compatibleWith: unit),
                   "The preferred unit is not compatiable with this sample.")
        }
        
        return unit
    }
    
    static func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
        var unit: HKUnit?
        let sampleType = sampleType ?? HKSampleType.getSampleType(for: identifier)
        
        if sampleType is HKQuantityType {
            let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
            
            switch quantityTypeIdentifier {
            case .stepCount:
                unit = .count()
            case .distanceWalkingRunning:
				unit = .meter()
			case .activeEnergyBurned:
				unit = .kilocalorie()
            case .appleExerciseTime:
                unit = .minute()
            default:
                break
            }
        }
        
        return unit
    }
}
