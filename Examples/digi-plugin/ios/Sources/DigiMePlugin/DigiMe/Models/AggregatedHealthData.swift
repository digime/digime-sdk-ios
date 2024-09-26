//
//  AggregatedHealthData.swift
//  DigiMeSDKExample
//
//  Created on 22/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

// Represents aggregated health data for a specific time range.
struct AggregatedHealthData {
    let startDate: Date
    let endDate: Date
    let minimum: Double?
    let maximum: Double?
    let average: Double?
}
