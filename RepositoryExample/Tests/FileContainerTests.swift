//
//  FileContainerTests.swift
//  DigiMeRepository_Tests
//
//  Created on 19/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import XCTest
@testable import DigiMeSDK

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSocialFile() {
        var file = "18_1_1_1_1_D201701_0.json"
        if let sut = FileContainer(withFileDescriptor: file) {
            verifySut(sut, group: .social, service: .facebook, object: .media, year: 2017, month: 1)
        }
        else {
            XCTFail("Unable to create file container for \(file)")
        }
        
        file = "18_1_4_1_2_D201701_1.json"
        if let sut = FileContainer(withFileDescriptor: file) {
            verifySut(sut, group: .social, service: .instagram, object: .post, year: 2017, month: 1)
            
        }
        else {
            XCTFail("Unable to create file container for \(file)")
        }
        
        file = "18_1_12_1_7_D201712_0.json"
        if let sut = FileContainer(withFileDescriptor: file) {
            verifySut(sut, group: .social, service: .flickr, object: .comment, year: 2017, month: 12)
        }
        else {
            XCTFail("Unable to create file container for \(file)")
        }
    }

    func verifySut(_ sut: FileContainer, group: CAServiceGroup, service: CAServiceType, object: CAObjectType, year: Int?, month: Int?) {
        XCTAssert(sut.group == group, "Expected \(group.rawValue), got \(sut.group.rawValue)")
        XCTAssert(sut.service == service, "Expected \(service.rawValue), got \(sut.service.rawValue)")
        XCTAssert(sut.objectType == object, "Expected \(object.rawValue), got \(sut.objectType.rawValue)")
        if
            let dateRange = sut.dateRange,
            let year = year,
            let month = month,
            let startDate = DateComponents(calendar: Calendar.current, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0).date,
            let endDate = DateComponents(calendar: Calendar.current, year: year, month: month + 1, day: 1, hour: 0, minute: 0, second: -1).date {
            XCTAssert(dateRange.start == startDate, "Expected \(startDate), got \(dateRange.start)")
            XCTAssert(dateRange.end == endDate, "Expected \(endDate), got \(dateRange.end)")
        }
        else {
            if sut.dateRange != nil {
                XCTFail("Expected nil, got \(String(describing: sut.dateRange))")
            }
            else {
                XCTFail("Expected date range, got nil")
            }
        }
    }
}
