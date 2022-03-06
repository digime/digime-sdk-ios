//
//  Date+Helper.swift
//  DigiMeSDKExample
//
//  Created on 28/02/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents)
    }
}
