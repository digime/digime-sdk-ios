//
//  TransactionCategoryType.swift
//  DigiMeRepository
//
//  Created on 19/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

/// The type of the category the transaction belongs to
///
/// - deferredCompensation: Deferred compensation type
/// - expense: Expense type
/// - income: Income
/// - transfer: Transfer type
/// - uncategorized: Transaction does not appear to be categorized
@objc public enum TransactionCategoryType: Int {
    case deferredCompensation
    case expense
    case income
    case transfer
    case uncategorized
    
    static func from(_ rawString: String) -> TransactionCategoryType {
        switch rawString {
        case "DEFERRED_COMPENSATION":
            return .deferredCompensation
        case "EXPENSE":
            return .expense
        case "INCOME":
            return .income
        case "TRANSFER":
            return .transfer
        default:
            return .uncategorized
        }
    }
}
