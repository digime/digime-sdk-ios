//
//  VehicleTest.swift
//  DigiMeSDK
//
//  Created on 06/12/2018.
//

import Foundation

@objcMembers
public class VehicleTest: NSObject, BaseObjectDecodable {
    
    public var accountIdentifier: String {
        return accountEntityId ?? ""
    }
    
    public static var objectType: CAObjectType {
        return .vehicleTest
    }
    
    public let advisoryNotes: [String]
    public let createdDate: Date
    public let entityId: String
    public let expiryDate: Date
    public let failureReasons: [String]
    public let identifier: String
    public let odometerReading: Int
    public let odometerUnit: String
    public var testResult: VehicleTestResult {
        return VehicleTestResult(rawValue: testResultRaw) ?? .unknown
    }
    
    // MARK: - Raw Representations
    private let testResultRaw: Int
    private let accountEntityId: String?
    
    // MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case accountEntityId = "accountentityid"
        case advisoryNotes = "advisorynotes"
        case createdDate = "createddate"
        case entityId = "entityid"
        case expiryDate = "expirydate"
        case failureReasons = "failurereasons"
        case identifier = "id"
        case odometerReading = "odometerreading"
        case odometerUnit = "odometerunit"
        case testResultRaw = "testresult"
    }
    
    override public init() {
        accountEntityId = nil
        advisoryNotes = []
        createdDate = Date()
        entityId = ""
        expiryDate = Date()
        failureReasons = []
        identifier = ""
        odometerReading = 0
        odometerUnit = ""
        testResultRaw = 0
    }
}
