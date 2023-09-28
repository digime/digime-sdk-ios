//
//  Extensions+HKSourceRevision.swift
//  DigiMeSDK
//
//  Created on 24.09.20.
//

import HealthKit

extension HKSourceRevision {
    var systemVersion: String {
        let major = operatingSystemVersion.majorVersion
        let minor = operatingSystemVersion.minorVersion
        let patch = operatingSystemVersion.patchVersion
        return "\(major).\(minor).\(patch)"
    }
}
