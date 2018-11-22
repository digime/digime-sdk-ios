//
//  TransactionCategorySource.swift
//  DigiMeRepository
//
//  Created on 19/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

/// Who assigned the category to the transacion
///
/// - system: System-defined category
/// - user: User-defined category
@objc public enum TransactionCategorySource: Int {
    case system
    case user
    
    static func from(_ rawString: String) -> TransactionCategorySource {
        switch rawString {
        case "USER":
            return .user
        default:
            return .system
        }
    }
}
