//
//  TimeRange.swift
//  DigiMeCore
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a time range scope with which data requests can be limited to
public enum TimeRange: Codable {
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let fromTimestamp = try? container.decode(Int.self, forKey: .from) {
            let fromDate = Date(timeIntervalSince1970: TimeInterval(fromTimestamp))
            
            if let toTimestamp = try? container.decode(Int.self, forKey: .to) {
                
                let toDate = Date(timeIntervalSince1970: TimeInterval(toTimestamp))
                self = .between(from: fromDate, to: toDate)
            }
            else {
                self = .after(from: fromDate)
            }
        }
        else if let toTimestamp = try? container.decode(Int.self, forKey: .to) {
            
            let toDate = Date(timeIntervalSince1970: TimeInterval(toTimestamp))
            self = .before(to: toDate)
        }
        else if
            let lastString = try? container.decode(String.self, forKey: .last),
            let lastRange = TimeRange.parseLastRange(from: lastString) {
            
            self = lastRange
        }
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid TimeRange data"))
        }
    }

    private static func parseLastRange(from string: String) -> TimeRange? {
        let regex = try! NSRegularExpression(pattern: "^(\\d+)([dmy])$")
        let range = NSRange(location: 0, length: string.utf16.count)
        if let match = regex.firstMatch(in: string, options: [], range: range) {
            let amount = Int((string as NSString).substring(with: match.range(at: 1)))!
            let unitRawValue = (string as NSString).substring(with: match.range(at: 2))
            if let unit = Unit(rawValue: unitRawValue) {
                return .last(amount: amount, unit: unit)
            }
        }
        
        return nil
    }
}
