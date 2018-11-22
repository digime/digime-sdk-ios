//
//  TransactionBaseType.swift
//  DigiMeRepository
//
//  Created on 19/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

/// Transaction type - whether transaction is being credited or debited
///
/// - credit: Transaction is being credited to the account
/// - debit: Transaction is being debited from the account
@objc public enum TransactionBaseType: Int {
    case credit
    case debit
    
    static func from(_ rawString: String) -> TransactionBaseType {
        switch rawString {
        case "CREDIT":
            return .credit
        default:
            return .debit
        }
    }
}
