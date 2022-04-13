//
//  HealthResult.swift
//  DigiMeSDK
//
//  Created on 18/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import HealthKit
import Foundation

public struct HealthResult: Codable {
    public var refreshedCredentials: Credentials?
    public var account: Account?
    public var data: [FitnessActivity]
}
