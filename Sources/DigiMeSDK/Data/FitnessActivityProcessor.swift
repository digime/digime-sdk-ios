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
        
        let cross = Dictionary(grouping: result, by: \.startDate).filter { $1.count > 1 }
        
        if cross.count > 0 {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Oooops", message: "Got duplicates from SDK: '\(cross.count)'", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(ok)
                UIViewController.topMostViewController()?.present(alert, animated: true)
            }
        }
        
        return result
    }
    
    // MARK: - Private
    
    private func isEmpty(object: FitnessActivitySummary) -> Bool {
        return (object.steps == 0 && (object.distances.first?.distance ?? 0) == 0 && object.calories == 0 && object.activity == 0)
    }
}
