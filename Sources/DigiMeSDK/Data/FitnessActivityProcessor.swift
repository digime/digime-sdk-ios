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
    static let dataTypes: [String] = [
        HKQuantityTypeIdentifier.stepCount.rawValue,
        HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
		HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
    ]
    
    func process(data: [String: [FitnessActivity]]) -> [FitnessActivity]? {
        guard
            let steps = data[HKQuantityTypeIdentifier.stepCount.rawValue],
            let walks = data[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue],
			let energy = data[HKQuantityTypeIdentifier.activeEnergyBurned.rawValue] else {
            return nil
        }
		
		// Merge all independent and separate results into the single one
        var result: [FitnessActivity] = []
		for activity in steps {
			if let walk = walks.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
				
				let binder = activity.merge(with: walk)
				
				if let spark = energy.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
					result.append(binder.merge(with: spark))
				}
				else {
					result.append(binder)
				}
			}
			else {
				result.append(activity)
			}
		}
        
        return isEmpty(data: result) ? nil : result
    }
    
    // MARK: - Private
    
    private func isEmpty(data: [FitnessActivity]) -> Bool {
        return !data.contains(where: { $0.steps > 0 || $0.distance > 0 || $0.activeEnergyBurned > 0 })
    }
}
