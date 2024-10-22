//
//  Extensions+HKSourceRevision.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
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
