//
//  Extensions+HKCategoryValueAudioExposureEvent.swift
//  DigiMeSDK
//
//  Created on 05.09.21.
//

import HealthKit

extension HKCategoryValueAudioExposureEvent: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueAudioExposureEvent"
    }
	
    public var detail: String {
        switch self {
        case .loudEnvironment:
            return "Load Environment"
        @unknown default:
            return "Unknown"
        }
    }
}
