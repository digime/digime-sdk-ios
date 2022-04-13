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
    ]
    
    func process(data: [String: [FitnessActivity]]) -> [FitnessActivity]? {
        guard
            let steps = data[HKQuantityTypeIdentifier.stepCount.rawValue],
            let walks = data[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue] else {
            return nil
        }
        
        var result: [FitnessActivity] = []
        
        for activity in steps {
            if let walk = walks.filter({ $0.startDate == activity.startDate && $0.endDate == activity.endDate }).first {
                result.append(activity.merge(with: walk))
            }
            else {
                result.append(activity)
            }
        }
        
        return isEmpty(data: result) ? nil : result
    }
    
    // MARK: - Private
    
    private func isEmpty(data: [FitnessActivity]) -> Bool {
        return !data.contains(where: { $0.steps > 0 || $0.distance > 0 })
    }
}
