//
//  ContractVersion5.swift
//  DigiMeSDK
//
//  Created on 11/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

public struct ContractVersion5: Codable {
    public let dataPush: DataPush?
    public let dataRequest: DataRequest?
    public let name: String?
    public let policies: Policies?
    public let resources: Resources?
    public let color: String?
    public let schemaVersion: String?
    public let revision: String?
    public let metadata: ContractMetadata?
    
    public func verifyTimeRange(readOptions: ReadOptions?) -> Result<TimeRangeLimits, SDKError> {
        let certDefaults = certificateTimeRange()
        if
            let readOptions = readOptions,
            let timeRange = readOptions.scope?.timeRanges?.first,
            let optionsRange = retrieveLimits(from: timeRange) {
            return .success(TimeRangeLimits(startDate: max(certDefaults.startDate, optionsRange.startDate), endDate: min(certDefaults.endDate, optionsRange.endDate)))
        }
        else {
            return .success(certDefaults)
        }
    }
	
	public func verifyTimeRange(startDate: Date, endDate: Date) -> TimeRangeLimits {
		let certDefaults = certificateTimeRange()
		return TimeRangeLimits(startDate: max(certDefaults.startDate, startDate), endDate: min(certDefaults.endDate, endDate))
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
        guard let range = dataRequest?.timeRanges?.first else {
            return maxRange
        }

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

public struct DataRequest: Codable {
    public let consentPolicy: ConsentPolicy?
    public let criteria: Criteria?
    public let dataImporter: DataImporter?
    public let dataRetention: DataRetentionPolicy?
    public let dataTransportPolicy: DataTransportPolicy?
    public let disclaimer: String?
    public let externalSharePolicy: ExternalSharePolicy?
    public let gdpr: GDPR?
    public let purpose: String?
    public let serviceGroups: [ServiceGroupCodable]?
    public let timeRanges: [ConsentAccessTimeRange]?
    
    enum CodingKeys: String, CodingKey {
        case consentPolicy
        case criteria
        case dataImporter
        case dataRetention
        case dataTransportPolicy
        case disclaimer
        case externalSharePolicy
        case gdpr
        case purpose
        case serviceGroups
        case timeRanges
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        consentPolicy = try container.decodeIfPresent(ConsentPolicy.self, forKey: .consentPolicy)
        criteria = try container.decodeIfPresent(Criteria.self, forKey: .criteria)
        dataImporter = try container.decodeIfPresent(DataImporter.self, forKey: .dataImporter)
        dataRetention = try container.decodeIfPresent(DataRetentionPolicy.self, forKey: .dataRetention)
        dataTransportPolicy = try container.decodeIfPresent(DataTransportPolicy.self, forKey: .dataTransportPolicy)
        disclaimer = try container.decodeIfPresent(String.self, forKey: .disclaimer)
        externalSharePolicy = try container.decodeIfPresent(ExternalSharePolicy.self, forKey: .externalSharePolicy)
        gdpr = try container.decodeIfPresent(GDPR.self, forKey: .gdpr)
        purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
        serviceGroups = try container.decodeIfPresent([ServiceGroupCodable].self, forKey: .serviceGroups)
        if let timeRangesCodable = try container.decodeIfPresent([TimeRangeCodable].self, forKey: .timeRanges) {
            var result = [ConsentAccessTimeRange]()
            timeRangesCodable.forEach { timeRange in
                
                if let timeRange = ConsentAccessTimeRange.timeRange(from: timeRange) {
                    result.append(timeRange)
                }
            }
            
            timeRanges = result
        }
        else {
            timeRanges = nil
        }
    }
}

public struct TimeRangeLimits: Codable {
    public let startDate: Date
    public let endDate: Date
}

public struct DataPush: Codable {
    public let type: String?
    public let purpose: String?
    public let frequency: String?
    public let content: [String]?
    public let mappedService: String?
    public let disclamer: String?
    public let callbackUrl: String?
    public let consentPolicy: String?
}

public struct ServiceObjectTypeCodable: Codable {
    public let id: Int?
}

public struct ServiceTypeCodable: Codable {
    public let id: Int?
    public let serviceObjectTypes: [ServiceObjectTypeCodable]?
}

public struct ServiceGroupCodable: Codable {
    public let id: Int?
    public let serviceTypes: [ServiceTypeCodable]?
}

public struct TimeRangeCodable: Codable {
    public let from: Double?
    public let to: Double?
    public let type: String?
    public let last: String?
}

public struct GDPR: Codable {
    public let description: String?
    public let canRequestRightToBeForgotten: Bool?
}

public struct ExternalSharePolicy: Codable {
    public let description: String?
    public let sharedExternally: Bool?
}

public struct DataTransportPolicy: Codable {
    public let description: String?
    public let leavesDevice: Bool?
}

public struct DataRetentionPolicy: Codable {
    public let dataRetained: Bool?
    public let description: String?
}

public struct DataImporter: Codable {
    public let name: String?
    public let resources: Resources?
}

public struct ConsentPolicy: Codable {
    public let description: String?
    public let shareType: String?
}

public struct Resources: Codable {
    public let termsAndConditions: String?
    public let homePage: String?
    public let privacyPolicy: String?
    public let terms: String?
    public let logo: String?
}

public struct Application: Codable {
    public let resources: Resources?
    public let schemaVersion: String?
    public let revision: Int?
    public let environment: Int?
    public let name: String?
    public let partnerId: String?
    public let status: Int?
}

public struct Partner: Codable {
    public let resources: Resources?
    public let schemaVersion: String?
    public let revision: Int?
    public let environment: Int?
    public let name: String?
    public let id: String?
    public let visibility: String?
}

public struct Criteria: Codable {
    // To be determined soon
}

public struct Policies: Codable {
    public let scope: String?
    public let properties: [String: String]?
    public let currentState: [String: String]?
}

public struct ContractMetadata: Codable {
    public let oAuth: OAuth?
}

public struct OAuth: Codable {
    public let deliveryMode: DeliveryMode?
}

public struct DeliveryMode: Codable {
    public let type: String
    public let redirectUri: String?
}

// MARK: - Convenience initializers

public extension ContractVersion5 {
    init?(data: Data) {
        guard let contract = try? data.decoded() as ContractVersion5 else {
            return nil
        }
        
        self = contract
    }

    init?(_ json: [AnyHashable: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        
        self.init(data: data)
    }
}
