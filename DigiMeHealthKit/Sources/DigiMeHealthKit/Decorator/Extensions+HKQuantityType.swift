//
//  Extensions+HKQuantityType.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import HealthKit

extension HKQuantityType {
    func parsed() throws -> QuantityType {
        for type in QuantityType.allCases {
            if type.identifier == identifier {
                return type
            }
        }
		throw SDKError.invalidType(message: "Unknown HKObjectType")
    }

    var statisticsOptions: HKStatisticsOptions {
        switch aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return [.discreteAverage, .discreteMax, .discreteMin]
        @unknown default:
            fatalError()
        }
    }
}
