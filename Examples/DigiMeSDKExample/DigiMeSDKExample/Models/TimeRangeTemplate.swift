//
//  TimeRangeTemplate.swift
//  DigiMeSDKExample
//
//  Created on 03/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct TimeRangeTemplate: Identifiable {
    var id = UUID()
    var name: String
    var timeRange: TimeRange?
}
