//
//  Date+Helper.swift
//  DigiMeSDK
//
//  Created on 17/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}

public extension Date {
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
