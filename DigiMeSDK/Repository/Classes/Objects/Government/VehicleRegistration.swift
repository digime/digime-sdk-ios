//
//  VehicleRegistration.swift
//  DigiMeSDK
//
//  Created on 06/12/2018.
//  Copyright © 2018 digi.me Ltd. All rights reserved.

import Foundation

@objcMembers
public class VehicleRegistration: NSObject, BaseObjectDecodable {
    
    public var accountIdentifier: String {
        return accountEntityId ?? ""
    }
    
    public static var objectType: CAObjectType {
        return .vehicleRegistration
    }
    
    public let createdDate: Date
    public let co2Emissions: Double
    public let colour: String
    public let engineCapacity: String
    public let entityId: String
    public let fuelType: String
    public let gearCount: Int
    public let identifier: String
    public let manufactureDate: Date
    public let make: String
    public let model: String
    public let registrationDate: Date
    public let seatingCapacity: Int
    public let transmission: String
    
    // MARK: - Raw Representations
    private let accountEntityId: String?
    
    // MARK: - Decadable
    enum CodingKeys: String, CodingKey {
        case accountEntityId = "accountentityid"
        case co2Emissions = "co2emissions"
        case colour = "colour"
        case createdDate = "createddate"
        case engineCapacity = "enginecapacity"
        case entityId = "entityid"
        case fuelType = "fueltype"
        case gearCount = "gearcount"
        case identifier = "id"
        case manufactureDate = "manufacturedate"
        case make = "make"
        case model = "model"
        case registrationDate = "registrationdate"
        case seatingCapacity = "seatingcapacity"
        case transmission = "transmission"
    }
}

