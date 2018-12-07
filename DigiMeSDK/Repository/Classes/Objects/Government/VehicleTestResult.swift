//
//  VehicleTestResult.swift
//  DigiMeSDK
//
//  Created on 06/12/2018.
//

import Foundation

@objc public enum VehicleTestResult: Int {
    case unknown = 0
    case pass = 1
    case fail = 2
    
    static func from(_ rawString: String) -> VehicleTestResult {
        switch rawString {
        case "PASS":
            return .pass
        case "FAIL":
            return .fail
        default:
            return .unknown
        }
    }
}
