//
//  Extensions+Date.swift
//  DigiMeSDK
//
//  Created on 14.09.20.
//

import Foundation

public extension Date {
    static var iso8601: String {
        return "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }

    func formatted(with format: String, timezone: TimeZone? = TimeZone.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        let date = dateFormatter.string(from: self)
        return date
    }

    static func make(from millisecondsSince1970: Double) -> Date {
        return Date(timeIntervalSince1970: millisecondsSince1970.secondsSince1970)
    }
}
