//
//  Date+Helper.swift
//  DigiMeCore
//
//  Created on 17/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

public extension Date {
    static func randomDateRange() -> (start: Date, end: Date) {
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date()

        let randomStartTimeInterval = TimeInterval.random(in: startDate.timeIntervalSince1970...endDate.timeIntervalSince1970)
        let randomStartDate = Date(timeIntervalSince1970: randomStartTimeInterval)

        let randomEndTimeInterval = TimeInterval.random(in: randomStartDate.timeIntervalSince1970...endDate.timeIntervalSince1970)
        let randomEndDate = Date(timeIntervalSince1970: randomEndTimeInterval)

        return (start: randomStartDate, end: randomEndDate)
    }

    static func from(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        return Calendar.utcCalendar.date(from: dateComponents)
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)) ~= self
    }
    
    func nextWeekOfYear(using calendar: Calendar = Calendar.utcCalendar) -> Int {
        calendar.component(.weekOfYear, from: self) + 1
    }
    
    func yearForWeekOfYear(using calendar: Calendar = Calendar.utcCalendar) -> Int {
        calendar.component(.yearForWeekOfYear, from: self)
    }
    
    func startOfNextWeek(using calendar: Calendar = Calendar.utcCalendar) -> Date {
        DateComponents(calendar: calendar, weekOfYear: nextWeekOfYear(using: calendar), yearForWeekOfYear: yearForWeekOfYear(using: calendar)).date!
    }
    
    var endOfToday: Date {
        let calendar = Calendar.utcCalendar
        let startOfDay = calendar.startOfDay(for: self)
        let components = DateComponents(hour: 23, minute: 59, second: 59)
        return calendar.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfDay: Date {
        return Calendar.utcCalendar.startOfDay(for: self)
    }

    var endOfTomorrow: Date {
        let components = DateComponents(day: 1)
        return Calendar.utcCalendar.date(byAdding: components, to: endOfToday)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.utcCalendar.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.utcCalendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.utcCalendar.date(byAdding: components, to: startOfMonth)!
    }

    var millisecondsSince1970: Double {
        (self.timeIntervalSince1970 * 1000.0).rounded()
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

public extension Date {
    static func date(year: Int, month: Int, day: Int = 1) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
}

public extension Date {
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withFullDate, .withFullTime, .withDashSeparatorInDate, .withFractionalSeconds]
        return formatter
    }()

    var iso8601String: String {
        return Date.iso8601Formatter.string(from: self)
    }
}
