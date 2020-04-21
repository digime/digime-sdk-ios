//
//  VehicleTests.swift
//  DigiMeRepository_Example
//
//  Created on 06/12/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

@testable import DigiMeSDK
import XCTest

class VehicleTests: XCTestCase {
    override func setUp() {
        // Setup code here.
    }
    
    override func tearDown() {
        // Teardown code here.
    }
    
    func testDecodeSingle() {
        
        let json =
        [
            "accountentityid": "25_MJ06NBA",
            "advisorynotes": [
                "rear axle buses split"
            ],
            "createddate": 1521824285000,
            "entityid": "25_MJ06NBA_7536 3645 5763",
            "expirydate": 1821824285000,
            "failurereasons": [
                "Offside Headlamp aim beam image obviously incorrect (1.8.A.1b)"
            ],
            "id": "7536 3645 5763",
            "odometerreading": 187479,
            "odometerunit": "mi",
            "testresult": 2
        ] as [String: Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = VehicleTest.decoder
            let vehicleTest = try decoder.decode(VehicleTest.self, from: data)
            
            var expectedDate = Date(timeIntervalSince1970: 1521824285000 / 1000)
            XCTAssert(vehicleTest.createdDate == expectedDate, "Expected createdDate: \(expectedDate) got \(vehicleTest.createdDate)")
            
            if let optionalDate = vehicleTest.expiryDate {
                expectedDate = Date(timeIntervalSince1970: 1821824285000 / 1000)
                XCTAssert(vehicleTest.expiryDate == optionalDate, "Expexted expiryDate: \(expectedDate) got \(optionalDate)")
            }
            
            XCTAssert(vehicleTest.entityId == "25_MJ06NBA_7536 3645 5763", "Expected entityId: 25_MJ06NBA_7536 3645 5763 \(vehicleTest.entityId)")
            XCTAssert(vehicleTest.accountIdentifier == "25_MJ06NBA", "Expected accountIdentifier: 25_MJ06NBA, got \(vehicleTest.accountIdentifier)")
            XCTAssert(vehicleTest.advisoryNotes.count == 1, "Expected '1', got \(vehicleTest.advisoryNotes.count)")
            XCTAssert(vehicleTest.advisoryNotes[0] == "rear axle buses split", "Expected 'rear axle buses split', got \(vehicleTest.advisoryNotes[0])")
            XCTAssert(vehicleTest.failureReasons.count == 1, "Expected '1', got \(vehicleTest.failureReasons.count)")
            XCTAssert(vehicleTest.failureReasons[0] == "Offside Headlamp aim beam image obviously incorrect (1.8.A.1b)", "Expected 'Offside Headlamp aim beam image obviously incorrect (1.8.A.1b)', got \(vehicleTest.failureReasons[0])")
            XCTAssert(vehicleTest.identifier == "7536 3645 5763", "Expected '7536 3645 5763', got \(vehicleTest.identifier)")
            XCTAssert(vehicleTest.odometerReading == 187479, "Expected '187479', got \(vehicleTest.odometerReading)")
            XCTAssert(vehicleTest.odometerUnit == "mi", "Expected 'mi', got \(vehicleTest.odometerUnit)")
            XCTAssert(vehicleTest.testResult.rawValue == 2, "Expected '2', got \(vehicleTest.testResult)")
        }
        catch {
            XCTFail("Unable to parse json Vechicle Test: \(error)")
        }
    }
    
    func testDecodeArray() {
        let data = """
[
{
    "accountentityid": "25_KA04UGR",
    "advisorynotes": [
         "very small amount of play in steering rack",
         "cover fitted under engine"
     ],
     "createddate": 1330387200000,
     "expirydate": 1361923200000,
     "failurereasons": [],
     "id": "736029952012",
     "entityid": "25_KA04UGR_736029952012",
     "odometerreading": 37566,
     "odometerunit": "mi",
     "testresult": 1
 },
 {
     "accountentityid": "25_KA04UGR",
     "advisorynotes": [
         "nail in lhr tyre",
         "boot cannot be opened from outsie vehicle",
         "very small amount of play in steering rack",
         "cover fitted under engine"
     ],
     "createddate": 1330387200000,
     "failurereasons": [
         "Nearside Front Windscreen wiper does not clear the windscreen effectively (8.2.2)",
         "Offside Front Windscreen wiper does not clear the windscreen effectively (8.2.2)",
         "Exhaust emits an excessive level of metered smoke for a turbo charged engine (7.4.B.3b)"
     ],
     "id": "949289352067",
     "entityid": "25_KA04UGR_949289352067",
     "odometerreading": 37566,
     "odometerunit": "mi",
     "testresult": 2
 },
 {
     "accountentityid": "25_KA04UGR",
     "advisorynotes": [
         "Nearside Front Tyre worn close to the legal limit (4.1.E.1)",
         "Offside Front Tyre worn close to the legal limit (4.1.E.1)"
     ],
     "createddate": 1454716800000,
     "failurereasons": [
         "Offside Front coil spring broken (2.4.C.1a)"
     ],
     "id": "498480060939",
     "entityid": "25_KA04UGR_498480060939",
     "odometerreading": 98495,
     "odometerunit": "mi",
     "testresult": 2
 }
]
""".data(using: .utf8)!
        do {
            let decoder = VehicleTest.decoder
            let vehicleTests = try decoder.decode([VehicleTest].self, from: data)
            XCTAssertNotNil(vehicleTests)
            XCTAssert(vehicleTests.count == 3, "Expected 3 vehicle tests, got \(vehicleTests.count)")
        }
        catch {
            XCTFail("Unable to parse json to Vechicle test array: \(error)")
        }
    }
}
