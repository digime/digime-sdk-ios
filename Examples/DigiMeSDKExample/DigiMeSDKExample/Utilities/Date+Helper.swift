//
//  Date+Helper.swift
//  DigiMeSDKExample
//
//  Created on 18/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

extension Date {
	static func date(year: Int, month: Int, day: Int = 1) -> Date {
		Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
	}
}

extension Date {
    func timeIntervalRetryDescription() -> String {
        let now = Date()
        let calendar = Calendar.current
        // Make sure the 'from' date is now, and 'to' date is the future date
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: self)

        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        var timeString = "Retry in "
        if days > 0 {
            timeString += "\(days) day" + (days > 1 ? "s " : " ")
        }
        if hours > 0 {
            timeString += "\(hours) hour" + (hours > 1 ? "s " : " ")
        }
        if minutes > 0 {
            timeString += "\(minutes) minute" + (minutes > 1 ? "s " : " ")
        }
        if seconds > 0 {
            timeString += "\(seconds) second" + (seconds > 1 ? "s " : " ")
        }
        
        return timeString.isEmpty ? "Retry now" : timeString.trimmingCharacters(in: .whitespaces)
    }

    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
}
