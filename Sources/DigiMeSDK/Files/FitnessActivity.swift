//
//  FitnessActivity.swift
//  DigiMeSDK
//
//  Created on 17/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

public struct FitnessActivity: Codable, Dated {
    public var identifier: String?         // "11018137805"
    public var entityId: String?           // "18_644MGZ_11018137805"
    public var accountEntityId: String?    // "18_644MGZ"
    public var activityName: String?       // "Walk"
    public var originalStartDate: Date?    // 1483628400000
    public var steps: Double               // 150
    public var distance: Double            // 100
    public var createdDate: Date?          // 1483628400000
    public var startDate: Date             // 1483628400000
    public var endDate: Date               // 1483628400000
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case entityId = "entityid"
        case accountEntityId = "accountentityid"
        case activityName = "activityname"
        case originalStartDate = "originalstartdate"
        case steps
        case distance
        case createdDate = "createddate"
        case startDate = "startdate"
        case endDate = "enddate"
    }
    
    public init(identifier: String?,
                entityId: String?,
                accountEntityId: String?,
                activityName: String?,
                originalStartDate: Date?,
                steps: Double,
                distance: Double,
                createdDate: Date?,
                startDate: Date,
                endDate: Date) {
        
        self.identifier = identifier
        self.entityId = entityId
        self.accountEntityId = accountEntityId
        self.activityName = activityName
        self.originalStartDate = originalStartDate
        self.steps = steps
        self.distance = distance
        self.createdDate = createdDate
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        entityId = try container.decodeIfPresent(String.self, forKey: .entityId)
        accountEntityId = try container.decodeIfPresent(String.self, forKey: .accountEntityId)
        activityName = try container.decodeIfPresent(String.self, forKey: .activityName)
        originalStartDate = try container.decodeIfPresent(Date.self, forKey: .originalStartDate)
        steps = try container.decode(Double.self, forKey: .steps)
        distance = try container.decode(Double.self, forKey: .distance)
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
    }
    
    public init(startDate: Date, endDate: Date, steps: Double, distance: Double, account: Account? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.steps = steps
        self.distance = distance
        let id = String.random(length: 11)
        self.identifier = id
        self.createdDate = Date()
        
        if let account = account {
            self.accountEntityId = account.identifier
            self.entityId = "\(account.identifier)_\(id)"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(entityId, forKey: .entityId)
        try container.encodeIfPresent(accountEntityId, forKey: .accountEntityId)
        try container.encodeIfPresent(activityName, forKey: .activityName)
        try container.encodeIfPresent(originalStartDate, forKey: .originalStartDate)
        try container.encode(steps, forKey: .steps)
        try container.encode(distance, forKey: .distance)
        try container.encodeIfPresent(createdDate, forKey: .createdDate)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
    }
}

public protocol Dated {
    var endDate: Date { get }
}

extension Array where Element: Dated {
    public func groupedBy(dateComponents: Set<Calendar.Component>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur.endDate)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
}

extension FitnessActivity {
    func merge(with: FitnessActivity) -> FitnessActivity {
        let new = FitnessActivity(
            identifier: identifier ?? with.identifier,
            entityId: entityId ?? with.entityId,
            accountEntityId: accountEntityId ?? with.accountEntityId,
            activityName: activityName ?? with.activityName,
            originalStartDate: originalStartDate ?? with.originalStartDate,
            steps: steps == 0.0 ? with.steps : steps,
            distance: distance == 0.0 ? with.distance : distance,
            createdDate: createdDate ?? with.createdDate,
            startDate: startDate,
            endDate: endDate)
        return new
    }
}
