//
//  Extensions+HKCategoryValueHeadphoneAudioExposureEvent.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 14.2, *)
extension HKCategoryValueHeadphoneAudioExposureEvent {
    public var description: String {
        "HKCategoryValueHeadphoneAudioExposureEvent"
    }
	
    public var detail: String {
        switch self {
        case .sevenDayLimit:
            return "Seven Day Limit"
        @unknown default:
            return "Unknown"
        }
    }
}
