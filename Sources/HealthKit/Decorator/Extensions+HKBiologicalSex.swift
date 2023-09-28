//
//  Extensions+HKBiologicalSex.swift
//  DigiMeSDK
//
//  Created on 15.09.20.
//

import HealthKit

extension HKBiologicalSex: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        @unknown default:
            fatalError()
        }
    }
}
