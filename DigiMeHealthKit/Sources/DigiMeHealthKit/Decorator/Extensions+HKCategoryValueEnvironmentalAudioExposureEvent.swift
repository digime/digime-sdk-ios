//
//  Extensions+HKCategoryValueEnvironmentalAudioExposureEvent.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 14.0, *)
extension HKCategoryValueEnvironmentalAudioExposureEvent {
    public var description: String {
        "HKCategoryValueEnvironmentalAudioExposureEvent"
    }
	
    public var detail: String {
        switch self {
        case .momentaryLimit:
            return "Momentary Limit"
        @unknown default:
            return "Unknown"
        }
    }
}
