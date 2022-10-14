//
//  FitnessActivityProcessor.swift
//  DigiMeSDK
//
//  Created on 02/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved
//

import Foundation
import HealthKit

class FitnessActivityProcessor {
    static let dataTypesRead: [String] = [
        HKQuantityTypeIdentifier.stepCount.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
		HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
        HKQuantityTypeIdentifier.appleExerciseTime.rawValue,
    ]
    
    static let dataTypesWrite: [String] = [
        HKQuantityTypeIdentifier.stepCount.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
        HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
    ]
    
    func process(data: [String: [FitnessActivitySummary]]) -> [FitnessActivitySummary]? {
        guard
            let steps = data[HKQuantityTypeIdentifier.stepCount.rawValue],
            let walks = data[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue],
			let energy = data[HKQuantityTypeIdentifier.activeEnergyBurned.rawValue],
            let active = data[HKQuantityTypeIdentifier.appleExerciseTime.rawValue] else {
            return nil
        }
		
		// Merge all independent and separate results into the single one
        var result: [FitnessActivitySummary] = []
		for activity in steps {
			if let walk = walks.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
				
				let binder = activity.merge(with: walk)
				
				if let filtered = energy.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
					result.append(binder.merge(with: filtered))
				}
				else {
					result.append(binder)
				}
                
                if let filtered = active.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
                    result.append(binder.merge(with: filtered))
                }
			}
			else {
				result.append(activity)
			}
		}
        
        return isEmpty(data: result) ? nil : result
    }
    
    // MARK: - Private
    
    private func isEmpty(data: [FitnessActivitySummary]) -> Bool {
        return !data.contains(where: { $0.steps > 0 || ($0.distances.first?.distance ?? 0) > 0 || $0.calories > 0 || $0.activity > 0 })
    }
}
