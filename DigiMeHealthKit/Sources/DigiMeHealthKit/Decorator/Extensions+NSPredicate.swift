//
//  Extensions+NSPredicate.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

public extension NSPredicate {
    static var allSamples: NSPredicate {
        return HKQuery.predicateForSamples(withStart: .distantPast, end: .distantFuture, options: [])
    }
	
    static func samplesPredicate(startDate: Date, endDate: Date, options: HKQueryOptions = [.strictStartDate, .strictEndDate]) -> NSPredicate {
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
    }

	static func activitySummaryPredicate(dateComponents: DateComponents) -> NSPredicate {
        return HKQuery.predicateForActivitySummary(with: dateComponents)
    }

	static func activitySummaryPredicateBetween(start: DateComponents, end: DateComponents) -> NSPredicate {
        return HKQuery.predicate(forActivitySummariesBetweenStart: start, end: end)
    }
}
