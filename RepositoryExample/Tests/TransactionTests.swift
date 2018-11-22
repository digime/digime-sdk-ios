//
//  TransactionTests.swift
//  DigiMeRepository_Tests
//
//  Created by Mike Eustace on 19/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import DigiMeSDK
import XCTest

class TransactionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodeSingle() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let json =
        [
            "accountentityid": "17_10084838",
            "amount": 286,
            "basetype": "DEBIT",
            "category": "Taxes",
            "categoryid": 37,
            "categorysource": "SYSTEM",
            "categorytype": "EXPENSE",
            "checknumber": "",
            "consumerref": "",
            "createddate": 1504483200000,
            "currency": "GBP",
            "entityid": "17_10084838_22819835",
            "highlevelcategoryid": 10000008,
            "id": "22819835",
            "ismanual": false,
            "merchantaddress1": "",
            "merchantaddress2": "",
            "merchantcity": "",
            "merchantcountry": "",
            "merchantid": "",
            "merchantname": "",
            "merchantstate": "",
            "merchantzip": "",
            "originalref": "DIRECT DEBIT PAYMENT TO COUNCIL TAX GBC REF XX XXXX2355, MANDATE NO 0024",
            "postdate": 1504483200000,
            "runningbalance": 23790.81,
            "runningbalancecurrency": "GBP",
            "simpleref": "Tax Payment",
            "status": "POSTED",
            "subtype": "TAX_PAYMENT",
            "type": "PAYMENT"
        ] as [String: Any]

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = Transaction.decoder
            let transaction = try decoder.decode(Transaction.self, from: data)
            XCTAssert(transaction.accountIdentifier == "17_10084838", "Expected accountIdentifier: 17_10084838, got \(transaction.accountIdentifier)")
            XCTAssert(transaction.amount == 286, "Expected amount: 286, got \(transaction.amount)")
            
            XCTAssert(transaction.baseType == .debit, "Expected baseType: debit, got \(transaction.baseType)")
            XCTAssert(transaction.category == .taxes, "Expected category: taxes, got \(transaction.category)")
            XCTAssert(transaction.categoryName == "Taxes", "Expected categoryName: Taxes, got \(transaction.categoryName)")
            XCTAssert(transaction.categorySource == .system, "Expected categorySource: system, got \(transaction.categorySource)")
            XCTAssert(transaction.categoryType == .expense, "Expected categoryType: expense, got \(transaction.categoryType)")
            XCTAssert(transaction.currency == "GBP", "Expected currency: GBP, got \(transaction.currency)")
            XCTAssert(transaction.originalRef == "DIRECT DEBIT PAYMENT TO COUNCIL TAX GBC REF XX XXXX2355, MANDATE NO 0024", "Expected originalRef: DIRECT DEBIT PAYMENT TO COUNCIL TAX GBC REF XX XXXX2355, MANDATE NO 0024, got \(transaction.originalRef)")
            XCTAssert(transaction.runningBalance == 23790.81, "Expected runningBalance: 23790.81, got \(transaction.runningBalance)")
            XCTAssert(transaction.runningBalanceCurrency == "GBP", "Expected runningBalanceCurrency: GBP, got \(transaction.runningBalanceCurrency)")
            XCTAssert(transaction.simpleRef == "Tax Payment", "Expected simpleRef: Tax Payment, got \(transaction.simpleRef)")
            XCTAssert(transaction.status == .posted, "Expected status: posted, got \(transaction.status)")
            XCTAssert(transaction.subType == "TAX_PAYMENT", "Expected subType: TAX_PAYMENT, got \(transaction.subType)")
            XCTAssert(transaction.type == "PAYMENT", "Expected type: PAYMENT, got \(transaction.type)")
            var expectedDate = Date(timeIntervalSince1970: 1504483200)
            XCTAssert(transaction.createdDate == expectedDate, "Expected createdDate: \(expectedDate), got \(transaction.createdDate)")
            expectedDate = Date(timeIntervalSince1970: 1504483200)
            XCTAssert(transaction.postDate == expectedDate, "Expected postDate: \(expectedDate), got \(transaction.postDate)")
            XCTAssertNil(transaction.transactionDate, "Expected transactionDate: nil, got \(String(describing: transaction.transactionDate))")
        }
        catch {
            XCTFail("Unable to convert json to Transaction: \(error)")
        }
    }
    
    func testDecodeArray() {
        let data = """
[
  {
    "accountentityid": "17_10084835",
    "amount": 9.24,
    "basetype": "CREDIT",
    "category": "Other Income",
    "categoryid": 32,
    "categorysource": "SYSTEM",
    "categorytype": "INCOME",
    "checknumber": "",
    "consumerref": "",
    "createddate": 1495411200000,
    "currency": "GBP",
    "entityid": "17_10084835_22819523",
    "highlevelcategoryid": 10000012,
    "id": "22819523",
    "ismanual": false,
    "merchantaddress1": "",
    "merchantaddress2": "",
    "merchantcity": "",
    "merchantcountry": "",
    "merchantid": "",
    "merchantname": "",
    "merchantstate": "",
    "merchantzip": "",
    "originalref": "INT'L XXXXXX4441 FIRST CLEAR *UK MALTA",
    "postdate": 1495411200000,
    "runningbalance": 0,
    "runningbalancecurrency": "",
    "simpleref": "INT'L XX41 FIRST CLEAR *UK MALTA",
    "status": "POSTED",
    "subtype": "CREDIT",
    "type": "OTHER_DEPOSITS"
  },
  {
    "accountentityid": "17_10084835",
    "amount": 8,
    "basetype": "DEBIT",
    "category": "Entertainment/Recreation",
    "categoryid": 7,
    "categorysource": "SYSTEM",
    "categorytype": "EXPENSE",
    "checknumber": "",
    "consumerref": "",
    "createddate": 1494806400000,
    "currency": "GBP",
    "entityid": "17_10084835_22819525",
    "highlevelcategoryid": 10000011,
    "id": "22819525",
    "ismanual": false,
    "merchantaddress1": "",
    "merchantaddress2": "",
    "merchantcity": "",
    "merchantcountry": "",
    "merchantid": "",
    "merchantname": "",
    "merchantstate": "",
    "merchantzip": "",
    "originalref": "FIRSTCLEAR LTD WIMBLEDON",
    "postdate": 1494806400000,
    "runningbalance": 0,
    "runningbalancecurrency": "",
    "simpleref": "FIRSTCLEAR LTD WIMBLEDON",
    "status": "POSTED",
    "subtype": "PAYMENT",
    "type": "PAYMENT"
  },
  {
    "accountentityid": "17_10084835",
    "amount": 9.99,
    "basetype": "DEBIT",
    "category": "Entertainment/Recreation",
    "categoryid": 7,
    "categorysource": "SYSTEM",
    "categorytype": "EXPENSE",
    "checknumber": "",
    "consumerref": "",
    "createddate": 1494806400000,
    "currency": "GBP",
    "entityid": "17_10084835_22819524",
    "highlevelcategoryid": 10000011,
    "id": "22819524",
    "ismanual": false,
    "merchantaddress1": "",
    "merchantaddress2": "",
    "merchantcity": "",
    "merchantcountry": "",
    "merchantid": "itunes",
    "merchantname": "iTunes",
    "merchantstate": "",
    "merchantzip": "",
    "originalref": "INT'L XXXXXX5697 ITUNES.COM/BILL ITUNES.COM",
    "postdate": 1494806400000,
    "runningbalance": 0,
    "runningbalancecurrency": "",
    "simpleref": "iTunes",
    "status": "POSTED",
    "subtype": "PAYMENT",
    "type": "PAYMENT"
  },
  {
    "accountentityid": "17_10084835",
    "amount": 250,
    "basetype": "CREDIT",
    "category": "Deposits",
    "categoryid": 27,
    "categorysource": "SYSTEM",
    "categorytype": "INCOME",
    "checknumber": "",
    "consumerref": "",
    "createddate": 1494201600000,
    "currency": "GBP",
    "entityid": "17_10084835_22819526",
    "highlevelcategoryid": 10000012,
    "id": "22819526",
    "ismanual": false,
    "merchantaddress1": "",
    "merchantaddress2": "",
    "merchantcity": "",
    "merchantcountry": "",
    "merchantid": "hsbcbank",
    "merchantname": "HSBC Bank",
    "merchantstate": "",
    "merchantzip": "",
    "originalref": "CHQ IN AT HSBC BANK PLC GUILDFORD",
    "postdate": 1494201600000,
    "runningbalance": 0,
    "runningbalancecurrency": "",
    "simpleref": "HSBC Bank",
    "status": "POSTED",
    "subtype": "CREDIT",
    "type": "OTHER_DEPOSITS"
  }
]
""".data(using: .utf8)!
        do {
            let decoder = Transaction.decoder
            let transactions = try decoder.decode([Transaction].self, from: data)
            XCTAssertNotNil(transactions)
            XCTAssert(transactions.count == 4, "Expected 4 transactions, got \(transactions.count)")
        }
        catch {
            XCTFail("Unable to convert json to Transaction array: \(error)")
        }
    }
}
