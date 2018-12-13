//
//  DMEFileContainer.swift
//  DigiMeRepository
//
//  Created on 12/07/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

/// Contains the attributes of the file
@objcMembers
public class FileContainer: NSObject {
    
    /// The object type the file contains
    public var objectType: CAObjectType
    
    /// The group the file belongs to
    public var group: CAServiceGroup
    
    /// The service the file relates to
    public var service: CAServiceType
    
    /// The date range the file spans, if applicable
    public var dateRange: DateInterval?
    
    /// The file name
    public var fileName: String
    
    public var created: Date?
    public var modified: Date?
    
    init?(withFileDescriptor descriptor: String) {
        guard
            let group = descriptor.group(),
            let service = descriptor.service(),
            let objectType = descriptor.objectType() else {
                return nil
        }
        
        self.fileName = descriptor
        self.group = group
        self.service = service
        self.objectType = objectType
        self.dateRange = descriptor.dateRange()
    }
}

fileprivate extension String {
    
    // These are the possible filenames:
    // jfsVersion _ group _ service _ accountIndex _ objectType _ encryptionStatus . json
    // jfsVersion _ group _ service _ accountIndex _ objectType _ dateRange _ encryptionStatus . json
    func jfsVersion() -> Int? {
        guard
            let versionString = descriptors()?.first,
            let version = Int(versionString) else {
                return nil
        }
        
        return version
    }
    
    func group() -> CAServiceGroup? {
        guard
            let descriptors = descriptors(),
            descriptors.indices.contains(1),
            let intVal = Int(descriptors[1]),
            let serviceGroup = CAServiceGroup(rawValue: intVal) else {
                return nil
        }
        
        return serviceGroup
    }
    
    func service() -> CAServiceType? {
        guard
            let descriptors = descriptors(),
            descriptors.indices.contains(2),
            let intVal = Int(descriptors[2]),
            let serviceType = CAServiceType(rawValue: intVal) else {
                return nil
        }
        
        return serviceType
    }
    
    func objectType() -> CAObjectType? {
        guard
            let descriptors = descriptors(),
            descriptors.indices.contains(4),
            let intVal = Int(descriptors[4]),
            let objectType = CAObjectType(rawValue: intVal) else {
                return nil
        }
        
        return objectType
    }
    
    func dateRange() -> DateInterval? {
        guard
            let descriptors = descriptors(),
            descriptors.indices.contains(6) else {
                return nil
        }
        
        let dateShard = descriptors[5]
        
        // Formats are:
        // AMMYY
        // BYY
        // CWWYY
        // DYYYYMM
        let format = dateShard.prefix(1)
        var month: Int?
        var week: Int?
        var year: Int?
        let startIndex = dateShard.index(dateShard.startIndex, offsetBy: 1)
        
        switch format {
        case "A":
            let yearIndex = dateShard.index(startIndex, offsetBy: 2)
            month = Int(dateShard[startIndex..<yearIndex])
            year = Int(dateShard[yearIndex...])
        case "B":
            week = Int(dateShard[startIndex...])
        case "C":
            let yearIndex = dateShard.index(startIndex, offsetBy: 2)
            week = Int(dateShard[startIndex..<yearIndex])
            year = Int(dateShard[yearIndex...])
        case "D":
            let monthIndex = dateShard.index(startIndex, offsetBy: 4)
            year = Int(dateShard[startIndex..<monthIndex])
            month = Int(dateShard[monthIndex...])
        default:
            return nil
        }
        
        let calendar = Calendar.current
        var startDateComponents = DateComponents()
        var endDateComponents = DateComponents()
        endDateComponents.second = -1
        
        if var startYear = year {
            if startYear < 100 {
                // Year is a 2-digit representation, so for all values greater than current year, assume last century
                startYear += 2000
                
                let currentYear = calendar.component(.year, from: Date())
                if startYear > currentYear {
                    startYear -= 100
                }
            }
            
            var endYear = startYear
            if format == "B" {
                endYear += 1
            }
            
            startDateComponents.year = startYear
            endDateComponents.year = endYear
        }
        
        if let startMonth = month {
            startDateComponents.month = startMonth
            endDateComponents.month = startMonth + 1
        }
        
        if let startWeek = week {
            startDateComponents.weekOfYear = startWeek
            endDateComponents.weekOfYear = startWeek + 1
        }
        
        guard
            let startDate = calendar.date(from: startDateComponents),
            let endDate = calendar.date(from: endDateComponents),
            startDate <= endDate else {
                return nil
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
    
    func descriptors() -> [String]? {
        let descriptors = self.components(separatedBy: "_")
        guard !descriptors.isEmpty else {
            return nil
        }
        
        return descriptors
    }
}
