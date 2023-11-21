//
//  ActivitySummaryType.swift
//  DigiMeSDK
//
//  Created on 05.10.20.
//

import HealthKit

/**
 All HealthKit activity summary types
 */
public enum ActivitySummaryType: Int, CaseIterable, ObjectType {
    case activitySummaryType

    public var original: HKObjectType? {
        switch self {
        case .activitySummaryType:
			return HKObjectType.activitySummaryType()
        }
    }
}
