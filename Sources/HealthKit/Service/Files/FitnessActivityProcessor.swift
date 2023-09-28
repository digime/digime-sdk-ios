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
	static var defaultTypesToRead: [ObjectType] {
		let types: [ObjectType] = [
			QuantityType.stepCount,
			QuantityType.distanceWalkingRunning,
			QuantityType.activeEnergyBurned,
			QuantityType.appleExerciseTime,
		]
		return types
	}

	static var defaultTypesToWrite: [ObjectType] {
		let types: [ObjectType] = [
			QuantityType.stepCount,
			QuantityType.distanceWalkingRunning,
			QuantityType.activeEnergyBurned,
		]
		return types
	}
    
    func process(data: [String: [FitnessActivitySummary]]) -> [FitnessActivitySummary]? {
        guard
			let steps = data[QuantityType.stepCount.original!.identifier],
            let walks = data[QuantityType.distanceWalkingRunning.original!.identifier],
			let energy = data[QuantityType.activeEnergyBurned.original!.identifier],
            let active = data[QuantityType.appleExerciseTime.original!.identifier] else {
            return nil
        }
		
		// Merge all independent and separate results into the single one
        var result: [FitnessActivitySummary] = []
		for activity in steps {
			if let walk = walks.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
				
				var binder = activity.merge(with: walk)
				
				if let filtered = energy.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
					binder = binder.merge(with: filtered)
				}
                
                if let filtered = active.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
                    binder = binder.merge(with: filtered)
                }

                if !isEmpty(object: binder) {
                    result.append(binder)
                }
			}
			else {
                if !isEmpty(object: activity) {
                    result.append(activity)
                }
			}
		}
        
        return result
    }
    
    // MARK: - Private
    
    private func isEmpty(object: FitnessActivitySummary) -> Bool {
        return (object.steps == 0 && (object.distances.first?.distance ?? 0) == 0 && object.calories == 0 && object.activity == 0)
    }
}
