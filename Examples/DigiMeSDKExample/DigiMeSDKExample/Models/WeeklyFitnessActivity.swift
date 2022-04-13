//
//  WeeklyFitnessActivity.swift
//  DigiMeSDKExample
//
//  Created on 17/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct WeeklyFitnessActivity {
    let typeIdentifier: String
    let startDate: Date
    let endDate: Date
    let data: [FitnessActivity]
}
