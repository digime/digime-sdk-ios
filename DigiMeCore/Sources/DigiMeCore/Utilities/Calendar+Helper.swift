//
//  Calendar+Helper.swift
//  DigiMeSDK
//
//  Created on 30/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

public extension Calendar {
    static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
}
