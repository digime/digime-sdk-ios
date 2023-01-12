//
//  Extensions+HKHeartbeatSeriesSample.swift
//  DigiMeSDK
//
//  Created on 12.10.21.
//

import HealthKit

extension HKHeartbeatSeriesSample {
    typealias Harmonized = HeartbeatSeries.Harmonized
    
	func harmonize(measurements: [HeartbeatSeries.Measurement]) -> Harmonized {
		return Harmonized(count: count,
						  measurements: measurements,
						  metadata: metadata?.asMetadata)
	}
}
