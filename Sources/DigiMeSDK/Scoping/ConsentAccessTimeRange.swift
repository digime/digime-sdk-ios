//
//  ConsentAccessTimeRange.swift
//  DigiMeSDK
//
//  Created on 21/02/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

public class ConsentAccessTimeRange: Codable {
    let type: ContractTimeRangeType
    let from: Date?
    let to: Date?
    let displayText: String
    
    public init(type: ContractTimeRangeType, description: String?, from: Date? = nil, to: Date? = nil) {
        self.type = type
        self.displayText = description ?? "unknown"
        self.from = from
        self.to = to
    }
	
	public func verifyTimeRange(readOptions: ReadOptions?) -> TimeRangeLimits {
		let certDefaults = certificateTimeRange()
		if
			let readOptions = readOptions,
			let timeRange = readOptions.scope?.timeRanges?.first,
			let optionsRange = retrieveLimits(from: timeRange) {
			
			let startDate = max(certDefaults.startDate, optionsRange.startDate)
			let endDate = min(certDefaults.endDate, optionsRange.endDate)
			let limits = TimeRangeLimits(startDate: startDate, endDate: endDate)
			return limits
		}
		else {
			return certDefaults
		}
	}
	
	public func verifyTimeRange(startDate: Date, endDate: Date) -> TimeRangeLimits {
		let certDefaults = certificateTimeRange()
		return TimeRangeLimits(startDate: max(certDefaults.startDate, startDate), endDate: min(certDefaults.endDate, endDate))
	}
	
	public func defaultLimits() -> TimeRangeLimits {
		return certificateTimeRange()
	}

	private func retrieveLimits(from timeRange: TimeRange) -> TimeRangeLimits? {
		let range = certificateTimeRange()
		
		switch timeRange {
		case .after(let from):
			return TimeRangeLimits(startDate: from, endDate: range.endDate)
		case .between(let from, let to):
			return TimeRangeLimits(startDate: from, endDate: to)
		case .before(let to):
			return TimeRangeLimits(startDate: range.startDate, endDate: to)
		case .last(let amount, let unit):
			return rolling(from: amount, unit: unit)
		}
	}
		
	private func rolling(from amount: Int, unit: TimeRange.Unit) -> TimeRangeLimits? {
		let calendar = Calendar.utcCalendar
		let now = Date()
		var dateComponents = DateComponents()
		
		switch unit {
		case .day:
			dateComponents.day = -(amount - 1)
		case .month:
			dateComponents.month = -amount
		case .year:
			dateComponents.year = -amount
		}
		
		guard let from = calendar.date(byAdding: dateComponents, to: now) else {
			return nil
		}
		
		return TimeRangeLimits(startDate: from, endDate: now)
	}
	
	private func certificateTimeRange() -> TimeRangeLimits {
		let maxStartDate = Date(timeIntervalSince1970: 0)
		let maxEndDate = Date().endOfToday
		let maxRange = TimeRangeLimits(startDate: maxStartDate, endDate: maxEndDate)
		let range = self
		
		switch range.type {
		case .window:
			if let from = range.from, let to = range.to {
				return TimeRangeLimits(startDate: from, endDate: to)
			}
		case .rolling,
				.since:
			if let startDate = range.from {
				return TimeRangeLimits(startDate: startDate, endDate: maxEndDate)
			}
		case .until:
			if let endDate = range.to {
				return TimeRangeLimits(startDate: maxStartDate, endDate: endDate)
			}
		case .allTime:
			return TimeRangeLimits(startDate: maxStartDate, endDate: maxEndDate)
		}
		
		return maxRange
	}
}

// MARK: - Class Functions
extension ConsentAccessTimeRange {
    class func timeRange(from timeRange: [String: Any]) -> ConsentAccessTimeRange? {
        let last = timeRange["last"] as? String
        let type = timeRange["type"] as? String
        let fromDate = date(from: timeRange["from"])
        let toDate = date(from: timeRange["to"])
        return ConsentAccessTimeRange.timeRange(type: type, toDate: toDate, fromDate: fromDate, last: last)
    }
    
    class func timeRange(from timeRange: TimeRangeCodable) -> ConsentAccessTimeRange? {
        let fromDate = date(from: timeRange.from)
        let toDate = date(from: timeRange.to)
        return ConsentAccessTimeRange.timeRange(type: timeRange.type, toDate: toDate, fromDate: fromDate, last: timeRange.last)
    }
    
    private class func timeRange(type: String?, toDate: Date?, fromDate: Date?, last: String?) -> ConsentAccessTimeRange? {
        var result: ConsentAccessTimeRange?
        
        switch (type, fromDate, toDate, last) {
            
        // All time
        case ("all", _, _, _):
            result = allTimeRange()
            
        // Window
        case let (nil, from, to, nil) as (String?, Date, Date, String?) where from < to:
            result = windowTimeRange(from: from, to: to)
            
        // Since
        case let (nil, from, nil, nil) as (String?, Date, Date?, String?):
            result = sinceTimeRange(from: from)
            
        // Until
        case let (nil, nil, to, nil) as (String?, Date?, Date, String?):
            result = untilTimeRange(to: to)
            
        // Rolling
        case let (nil, nil, nil, last) as (String?, Date?, Date?, String) where last.count >= 2:
            result = rollingTimeRangeFromRangeDescriptor(last)
            
        default:
            result = nil
        }
        
        return result
    }
    
    private class func date(from anyValue: Any?) -> Date? {
        guard let anyValue = anyValue else {
            return nil
        }
        
        if let timestamp = anyValue as? Double {
            return Date(timeIntervalSince1970: timestamp)
        }
        
        if let timestamp = anyValue as? Int {
            return Date(timeIntervalSince1970: Double(timestamp))
        }
        
        return nil
    }
    
    private class func windowTimeRange(from: Date, to: Date) -> ConsentAccessTimeRange {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let formattedFrom = dateFormatter.string(from: from)
        let formattedTo = dateFormatter.string(from: to)
        let format = "From %1$@ to %2$@"
        let description = String(format: format, formattedFrom, formattedTo)
        return ConsentAccessTimeRange(type: .window, description: description, from: from, to: to)
    }
    
    private class func sinceTimeRange(from: Date) -> ConsentAccessTimeRange {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let formattedFrom = dateFormatter.string(from: from)
        let format = "Since %@"
        let description = String(format: format, formattedFrom)
        return ConsentAccessTimeRange(type: .since, description: description, from: from)
    }
    
    private class func untilTimeRange(to: Date) -> ConsentAccessTimeRange {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let formattedTo = dateFormatter.string(from: to)
        let format = "Until %@"
        let description = String(format: format, formattedTo)
        return ConsentAccessTimeRange(type: .until, description: description, to: to)
    }
    
    private class func allTimeRange() -> ConsentAccessTimeRange {
        let description = "All time"
        return ConsentAccessTimeRange(type: .allTime, description: description)
    }
    
    private class func rollingTimeRangeFromRangeDescriptor(_ descriptor: String) -> ConsentAccessTimeRange? {
        var mutableDescriptor = descriptor
        guard
            let unitPart = mutableDescriptor.popLast(),
            let unit = RollingUnit(rawValue: String(unitPart)),
            let value = Int(mutableDescriptor),
            value > 0 else {
                return nil
        }
        
        var dateComponents = DateComponents()
        var format: String?
        switch unit {
        case .hour:
            dateComponents.hour = -value
            format = "Last %li hours"
        case .day:
            dateComponents.day = -value
            format = "Last %li days"
        case .month:
            dateComponents.month = -value
            format = "Last %li months"
        case .year:
            dateComponents.year = -value
            format = "Last %li years"
        }
        
        var description: String?
        if let format = format {
            description = String.localizedStringWithFormat(format, value)
        }
        
        let from = Calendar.current.date(byAdding: dateComponents, to: Date())
        return ConsentAccessTimeRange(type: .rolling, description: description, from: from)
    }
}

fileprivate enum RollingUnit: String {
    case hour = "h"
    case day = "d"
    case month = "m"
    case year = "y"
}
