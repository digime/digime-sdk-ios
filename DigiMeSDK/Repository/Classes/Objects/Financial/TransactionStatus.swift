//
//  TransactionStatus.swift
//  DigiMeRepository
//
//  Created on 19/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objc public enum TransactionStatus: Int {
    case failed
    case pending
    case posted
    case scheduled
    
    static func from(_ rawString: String) -> TransactionStatus {
        switch rawString {
        case "POSTED":
            return .posted
        case "PENDING":
            return .pending
        case "SCHEDULED":
            return.scheduled
        case "FAILED":
            return .failed
        default:
            return .posted
        }
    }
}
