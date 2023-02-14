//
//  TimeRange.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a time range scope with which data requests can be limited to
public enum TimeRange: Encodable {
    public enum Unit: String {
        case day = "d"
        case month = "m"
        case year = "y"
		
		public var calendarUnit: Calendar.Component {
			switch self {
			case .month:
				return Calendar.Component.month
			case .year:
				return Calendar.Component.year
			default:
				return Calendar.Component.day
			}
		}
    }
    
    case after(from: Date)
    case between(from: Date, to: Date)
    case before(to: Date)
    case last(amount: Int, unit: Unit)
    
    enum CodingKeys: String, CodingKey {
        case from, to, last
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .after(let from):
            try container.encode(Int(from.timeIntervalSince1970), forKey: .from)
        case let .between(from, to):
            // Allow for cases where user has inadvertently set the `to` date to before the `from` date
            let firstDate = min(from, to)
            let lastDate = max(from, to)
            try container.encode(Int(firstDate.timeIntervalSince1970), forKey: .from)
            try container.encode(Int(lastDate.timeIntervalSince1970), forKey: .to)
        case .before(let to):
            try container.encode(Int(to.timeIntervalSince1970), forKey: .to)
        case let .last(amount, unit):
            try container.encode("\(amount)\(unit.rawValue)", forKey: .last)
        }
    }
}
