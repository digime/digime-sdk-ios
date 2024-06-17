//
//  AggregationMethod.swift
//  DigiMeSDKExample
//
//  Created on 15/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

enum AggregationMethod: String, CaseIterable, Identifiable {
    case none = "No Aggregation"
    case daily = "Daily Summary"
    case weekly = "Weekly Summary"
    case monthly = "Monthly Summary"

    var id: String { self.rawValue }
}
