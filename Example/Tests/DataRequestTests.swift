//
//  DataRequestTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 12/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import XCTest
@testable import DigiMeSDK

class DataRequestTests: XCTestCase {

    let refFromDate = Date(timeIntervalSince1970: 1556928000)
    let refToDate = Date(timeIntervalSince1970: 1557014400)
    
    func testDefaultScopeObjectShouldHaveScopeContext() {
        let sut = DMEScope()
        XCTAssertEqual(sut.context, "scope", "Expected default scope context to equal `scope`")
    }
    
    func testFromTimeRange() {
        let sut = DMETimeRange.from(refFromDate)
        XCTAssertNotNil(sut.from, "`from` date should not be nil")
        XCTAssertEqual(sut.from?.timeIntervalSince1970, refFromDate.timeIntervalSince1970, "`from` timeinterval does not match expected date \(refFromDate.timeIntervalSince1970).")
        XCTAssertNil(sut.to, "`to` date should be nil")
        XCTAssertNil(sut.last, "`last` literal should be nil")
    }

    func testPriorToTimeRange() {
        let sut = DMETimeRange.prior(to: refToDate)
        XCTAssertNotNil(sut.to, "`to` date should not be nil")
        XCTAssertEqual(sut.to?.timeIntervalSince1970, refToDate.timeIntervalSince1970, "`to` timeinterval does not match expected date \(refToDate.timeIntervalSince1970).")
        XCTAssertNil(sut.from, "`from` date should be nil")
        XCTAssertNil(sut.last, "`last` literal should be nil")
    }
    
    func testFromToTimeRange() {
        let sut = DMETimeRange.from(refFromDate, to: refToDate)
        XCTAssertNotNil(sut.to, "`to` date should not be nil")
        XCTAssertNotNil(sut.from, "`from` date should not be nil")
        XCTAssertEqual(sut.from?.timeIntervalSince1970, refFromDate.timeIntervalSince1970, "`from` timeinterval does not match expected date \(refFromDate.timeIntervalSince1970).")
        XCTAssertEqual(sut.to?.timeIntervalSince1970, refToDate.timeIntervalSince1970, "`to` timeinterval does not match expected date \(refToDate.timeIntervalSince1970).")
        XCTAssertNil(sut.last, "`last` literal should be nil")
    }
    
    func testLastXDaysUnit() {
        let sut = DMETimeRange.last(10, unit: .day)
        XCTAssertNil(sut.from, "`from` date should be nil")
        XCTAssertNil(sut.to, "`to` date should be nil")
        XCTAssertNotNil(sut.last, "`last` literal should be nil")
        XCTAssertEqual(sut.last, "10d", "`last` literal does not match expected.")
    }
    
    func testLastXMonthsUnit() {
        let sut = DMETimeRange.last(11, unit: .month)
        XCTAssertNil(sut.from, "`from` date should be nil")
        XCTAssertNil(sut.to, "`to` date should be nil")
        XCTAssertNotNil(sut.last, "`last` literal should be nil")
        XCTAssertEqual(sut.last, "11m", "`last` literal does not match expected.")
    }
    
    func testLastXYearsUnit() {
        let sut = DMETimeRange.last(1, unit: .year)
        XCTAssertNil(sut.from, "`from` date should be nil")
        XCTAssertNil(sut.to, "`to` date should be nil")
        XCTAssertNotNil(sut.last, "`last` literal should be nil")
        XCTAssertEqual(sut.last, "1y", "`last` literal does not match expected.")
    }
}
