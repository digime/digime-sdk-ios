//
//  VehicleRegistrationTests.swift
//  DigiMeRepository_Example
//
//  Created on 10/12/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@testable import DigiMeSDK
import XCTest

class VehicleRegistrationTests: XCTestCase {
    override func setUp() {
        // Setup code here
    }
    
    override func tearDown() {
        // Teardown code here
    }
    
    func testDecodeSingle() {
        
        let json =
        [
            "accountentityid": "25_MJ06NBA",
            "co2emissions": 167.0,
            "colour": "SILVER",
            "createddate": 1521824285000,
            "enginecapacity": "1910",
            "entityid": "25_MJ06NBA_1521824285000",
            "fueltype": "DIESEL",
            "gearcount": 6,
            "id": "1521824285000",
            "manufacturedate": 123651286382,
            "make": "VAUXHALL",
            "model": "ZAFIRA DESIGN CDTI 150 E4",
            "registrationdate": 187235817236,
            "seatingcapacity": 7,
            "transmission": "Manual"
        ] as [String: Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = VehicleRegistration.decoder
            let vehicleRegistrationTest = try decoder.decode(VehicleRegistration.self, from: data)
            
            var expectedDate = Date(timeIntervalSince1970: 1521824285000 / 1000)
            XCTAssert(vehicleRegistrationTest.createdDate == expectedDate, "Expected createdDate: \(expectedDate) got \(vehicleRegistrationTest.createdDate)")
            expectedDate = Date(timeIntervalSince1970: 123651286382 / 1000)
            XCTAssert(vehicleRegistrationTest.manufactureDate == expectedDate, "Expected manufactureDate: \(expectedDate) got \(vehicleRegistrationTest.manufactureDate)")
            expectedDate = Date(timeIntervalSince1970: 187235817236 / 1000)
            XCTAssert(vehicleRegistrationTest.registrationDate == expectedDate, "Expected registrationDate: \(expectedDate) got \(vehicleRegistrationTest.registrationDate)")

            XCTAssert(vehicleRegistrationTest.accountIdentifier == "25_MJ06NBA", "Expected accountEntityId '25_MJ06NBA' got \(vehicleRegistrationTest.accountIdentifier)")
            XCTAssert(vehicleRegistrationTest.co2Emissions == 167.0, "Expected co2Emissions '167.0' got \(vehicleRegistrationTest.co2Emissions)")
            XCTAssert(vehicleRegistrationTest.colour == "SILVER", "Expected colour 'SILVER' got \(vehicleRegistrationTest.colour)")
            XCTAssert(vehicleRegistrationTest.engineCapacity == "1910", "Expected engineCapacity '1910' got \(vehicleRegistrationTest.engineCapacity)")
            XCTAssert(vehicleRegistrationTest.entityId == "25_MJ06NBA_1521824285000", "Expected entityId '25_MJ06NBA_1521824285000' got \(vehicleRegistrationTest.entityId)")
            XCTAssert(vehicleRegistrationTest.fuelType == "DIESEL", "Expected fuelType 'DIESEL' got \(vehicleRegistrationTest.fuelType)")
            XCTAssert(vehicleRegistrationTest.gearCount == 6, "Expected gearCount '6' got \(vehicleRegistrationTest.gearCount)")
            XCTAssert(vehicleRegistrationTest.identifier == "1521824285000", "Expected '1521824285000' got \(vehicleRegistrationTest.identifier)")
            XCTAssert(vehicleRegistrationTest.make == "VAUXHALL", "Expected identifier 'VAUXHALL' got \(vehicleRegistrationTest.make)")
            XCTAssert(vehicleRegistrationTest.model == "ZAFIRA DESIGN CDTI 150 E4", "Expected model 'ZAFIRA DESIGN CDTI 150 E4' got \(vehicleRegistrationTest.model)")
            XCTAssert(vehicleRegistrationTest.seatingCapacity == 7, "Expected seatingCapacity '7' got \(vehicleRegistrationTest.seatingCapacity)")
            XCTAssert(vehicleRegistrationTest.transmission == "Manual", "Expected transmission 'Manual' got \(vehicleRegistrationTest.transmission)")
        }
        catch {
            XCTFail("Unable to parse json Vehicke Registartion Test: \(error)")
        }
    }
}
