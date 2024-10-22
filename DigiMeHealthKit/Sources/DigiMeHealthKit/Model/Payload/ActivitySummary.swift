//
//  ActivitySummary.swift
//  DigiMeHealthKit
//
//  Created on 25.09.20.
//

import CryptoKit
import HealthKit

public struct ActivitySummary: PayloadIdentifiable {
    public struct Harmonized: Codable {
        public let activeEnergyBurned: Double
        public let activeEnergyBurnedGoal: Double
        public let activeEnergyBurnedUnit: String
        public let appleExerciseTime: Double
        public let appleExerciseTimeGoal: Double
        public let appleExerciseTimeUnit: String
        public let appleStandHours: Double
        public let appleStandHoursGoal: Double
        public let appleStandHoursUnit: String
    }

    public let id: String
    public let identifier: String
    public let date: String?
    public let harmonized: Harmonized

    init(activitySummary: HKActivitySummary) throws {
        self.identifier = ActivitySummaryType
            .activitySummaryType
            .original?
            .identifier ?? "HKActivitySummaryTypeIdentifier"
        self.date = activitySummary
            .dateComponents(for: Calendar.current)
            .date?
            .formatted(with: Date.iso8601)
        self.harmonized = try activitySummary.harmonize()
        self.id = Self.generateHashId(identifier: self.identifier, date: self.date, harmonized: self.harmonized)
    }

    private static func generateHashId(identifier: String, date: String?, harmonized: Harmonized) -> String {
        let idString = "\(identifier)_\(date ?? "")_\(harmonized.activeEnergyBurned)_\(harmonized.appleExerciseTime)_\(harmonized.appleStandHours)"
        let inputData = Data(idString.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        return String(format: "%@-%@-%@-%@-%@",
                      String(hashString.prefix(8)),
                      String(hashString.dropFirst(8).prefix(4)),
                      String(hashString.dropFirst(12).prefix(4)),
                      String(hashString.dropFirst(16).prefix(4)),
                      String(hashString.dropFirst(20).prefix(12))
        )
    }
}
