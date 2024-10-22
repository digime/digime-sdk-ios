//
//  Extensions+HKHeartbeatSeriesSample.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
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
