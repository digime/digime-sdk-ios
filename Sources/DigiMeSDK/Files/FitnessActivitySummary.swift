//
//  FitnessActivity.swift
//  DigiMeSDK
//
//  Created on 17/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

public struct FitnessActivitySummary: Codable, Dated, Identifiable {
    public struct Distances: Codable {
        public var activity: String
        public var distance: Double
		
		public init(activity: String, distance: Double) {
			self.activity = activity
			self.distance = distance
		}
    }
    
	public var id: String
    public var identifier: String?
    public var entityId: String?
    public var accountEntityId: String?
    public var steps: Double
    public var distances: [Distances]
    public var createdDate: Date?
    public var startDate: Date
    public var endDate: Date
    public var calories: Double
    public var activity: Int
    
    enum CodingKeys: String, CodingKey {
		case id = "guid"
        case identifier = "id"
        case entityId = "entityid"
        case accountEntityId = "accountentityid"
        case originalStartDate = "originalstartdate"
        case steps
        case distances
        case createdDate = "createddate"
        case startDate = "startdate"
        case endDate = "enddate"
        case calories = "caloriesout"
        case activity = "veryactiveminutes"
    }
    
    public init(identifier: String?,
                entityId: String?,
                accountEntityId: String?,
                steps: Double,
                distances: [Distances],
                calories: Double,
                activity: Int,
                createdDate: Date?,
                startDate: Date,
                endDate: Date) {
        
		self.id = UUID().uuidString.lowercased()
        self.identifier = identifier
        self.entityId = entityId
        self.accountEntityId = accountEntityId
        self.steps = steps
        self.distances = distances
        self.calories = calories
        self.activity = activity
        self.createdDate = createdDate
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .identifier) ?? UUID().uuidString.lowercased()
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        entityId = try container.decodeIfPresent(String.self, forKey: .entityId)
        accountEntityId = try container.decodeIfPresent(String.self, forKey: .accountEntityId)
        steps = try container.decode(Double.self, forKey: .steps)
        distances = try container.decode([Distances].self, forKey: .distances)
        calories = try container.decode(Double.self, forKey: .calories)
        activity = try container.decode(Int.self, forKey: .activity)
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
    }
    
    public init(startDate: Date, endDate: Date, steps: Double, distances: [Distances], calories: Double, activity: Int, account: SourceAccount? = nil) {
		self.id = UUID().uuidString.lowercased()
        self.startDate = startDate
        self.endDate = endDate
        self.steps = steps
        self.distances = distances
        self.calories = calories
        self.activity = activity
        let id = String(Int(startDate.millisecondsSince1970))
        self.identifier = id
        self.createdDate = startDate
        
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
        try container.encode(steps, forKey: .steps)
        try container.encode(distances, forKey: .distances)
        try container.encode(calories, forKey: .calories)
        try container.encode(activity, forKey: .activity)
        try container.encodeIfPresent(createdDate, forKey: .createdDate)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
    }
}

public protocol Dated {
    var endDate: Date { get }
}

extension Array where Element: Dated {
	public func groupedBy(dateComponents: Set<Calendar.Component>, shiftDateToMiddle: Bool = false) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            var components = Calendar.current.dateComponents(dateComponents, from: cur.endDate)
			
			if shiftDateToMiddle {
				components.day = 15
			}
			
			let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
}

extension FitnessActivitySummary {
    func merge(with: FitnessActivitySummary) -> FitnessActivitySummary {
        let new = FitnessActivitySummary(
            identifier: identifier ?? with.identifier,
            entityId: entityId ?? with.entityId,
            accountEntityId: accountEntityId ?? with.accountEntityId,
            steps: steps == 0.0 ? with.steps : steps,
            distances: (distances.first?.distance ?? 0.0) == 0.0 ? with.distances : distances,
            calories: calories == 0.0 ? with.calories : calories,
            activity: activity == 0 ? with.activity : activity,
            createdDate: createdDate ?? with.createdDate,
            startDate: startDate,
            endDate: endDate)
        return new
    }
}
