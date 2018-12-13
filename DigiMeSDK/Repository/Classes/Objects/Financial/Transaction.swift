//
//  Transaction.swift
//  DigiMeRepository
//
//  Created on 18/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class Transaction: NSObject, BaseObjectDecodable {
    
    public static var objectType: CAObjectType {
        return .transaction
    }
    
    /// The identifier of the account from which the transaction was made
    public let accountIdentifier: String
    
    /// The value provided will be either postDate or transactionDate.
    /// postDate takes higher priority than transactionDate.
    /// The availability of postDate or transactionDate depends on the provider site.
    public let createdDate: Date
    
    /// A unique identifier for the transaction
    public let identifier: String

    /// The amount of the transaction as it appears at the financial institute site
    public let amount: Double

    /// Indicates if the transaction appears as a dbit or credit
    public var baseType: TransactionBaseType {
        return TransactionBaseType.from(baseTypeRaw)
    }

    /// The name of the category assigned to the transaction
    public var categoryName: String {
        return categoryRaw
    }

    /// The category assigned to the transaction
    public var category: TransactionCategory {
        return TransactionCategory.from(categoryID)
    }

    /// Indicates the source of the category, i.e., categories derived by the system or assigned/provided by the consumer
    public var categorySource: TransactionCategorySource {
        return TransactionCategorySource.from(categorySourceRaw)
    }

    /// The type of the category assigned to the transaction
    public var categoryType: TransactionCategoryType {
        return TransactionCategoryType.from(categoryTypeRaw)
    }

    /// The serial number of the check, if applicable
    public let checkNumber: String

    /// The description of the transaction as defined by the consumer
    public let consumerRef: String

    /// The three letter ISO code for the currency of the transaction
    public let currency: String

    /// The high level category assigned to the transaction
    public let highlevelCategoryID: Int

    /// Indictaes whether the transation is aggregated from the financial
    /// institute (`false`) or the consumer has manually created the transaction (`true`)
    public let isManual: Bool

    /// First line of the merchant's address, if available
    public let merchantAddress1: String

    /// Second line of the merchant's address, if available
    public let merchantAddress2: String

    /// The city of the merchant's address, if available
    public let merchantCity: String

    /// The two-letter ISO country code of the merchant's address, if available.
    public let merchantCountry: String

    /// The identifier of the merchant, if available
    public let merchantID: String

    /// The name of the merchant, if available
    public let merchantName: String

    /// The state of the merchant's address, if available
    public let merchantState: String

    /// The zip code of the merchant's address, if available
    public let merchantZip: String

    /// Original transaction description as it appears at the financial institute site
    public let originalRef: String

    /// The date on which the transaction is posted to the account.
    public let postDate: Date

    /// The balance of the account after the transaction
    public let runningBalance: Double

    /// The three letter ISO code for the currency of the account balance
    public let runningBalanceCurrency: String

    /// The transaction description that appears at the financial institute
    /// site may not be self-explanatory,
    /// i.e., the source, purpose of the transaction may not be evident.
    /// This is an attempt to simplify and make the transaction meaningful to the consumer.
    public let simpleRef: String

    /// The status of the transaction: pending or posted.
    /// Note: Most financial institute sites only display posted transactions.
    /// If the financial institute site displays transaction status, same will be aggregated.
    public var status: TransactionStatus {
        return TransactionStatus.from(statusRaw)
    }
    /// The transaction subtype field provides a detailed transaction type, if known
    public let subType: String

    /// The date the transaction happens in the account
    public let transactionDate: Date?

    /// The nature of the transaction, if known
    public let type: String

    private let baseTypeRaw: String
    private let categoryRaw: String
    private let categoryID: Int
    private let categorySourceRaw: String
    private let categoryTypeRaw: String
    private let statusRaw: String
    
    enum CodingKeys: String, CodingKey {
        case accountIdentifier = "accountentityid"
        case createdDate = "createddate"
        case identifier = "entityid"
        case amount
        case baseTypeRaw = "basetype"
        case categoryRaw = "category"
        case categoryID = "categoryid"
        case categorySourceRaw = "categorysource"
        case categoryTypeRaw = "categorytype"
        case checkNumber = "checknumber"
        case consumerRef = "consumerref"
        case currency
        case highlevelCategoryID = "highlevelcategoryid"
        case isManual = "ismanual"
        case merchantAddress1 = "merchantaddress1"
        case merchantAddress2 = "merchantaddress2"
        case merchantCity = "merchantcity"
        case merchantCountry = "merchantcountry"
        case merchantID = "merchantid"
        case merchantName = "merchantname"
        case merchantState = "merchantstate"
        case merchantZip = "merchantzip"
        case originalRef = "originalref"
        case postDate = "postdate"
        case runningBalance = "runningbalance"
        case runningBalanceCurrency = "runningbalancecurrency"
        case simpleRef = "simpleref"
        case statusRaw = "status"
        case subType = "subtype"
        case transactionDate = "transactiondate"
        case type
    }
    
    override private init() {
        accountIdentifier = ""
        identifier = ""
        createdDate = Date()
        amount = 0
        baseTypeRaw = ""
        categoryRaw = ""
        categoryID = 0
        categorySourceRaw = ""
        categoryTypeRaw = ""
        checkNumber = ""
        consumerRef = ""
        currency = ""
        highlevelCategoryID = 0
        isManual = false
        merchantAddress1 = ""
        merchantAddress2 = ""
        merchantCity = ""
        merchantCountry = ""
        merchantID = ""
        merchantName = ""
        merchantState = ""
        merchantZip = ""
        originalRef = ""
        postDate = Date()
        runningBalance = 0
        runningBalanceCurrency = ""
        simpleRef = ""
        statusRaw = ""
        subType = ""
        transactionDate = nil
        type = ""
    }
}
