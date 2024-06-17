//
//  CryptographyTests+Helper.swift
//  DigiMeSDKExampleTests
//
//  Created on 29/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

func areEqualDictionaries(_ lhs: [String: Any]?, _ rhs: [String: Any]?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
        return lhs == nil && rhs == nil
    }

    if lhs.count != rhs.count {
        return false
    }

    for (key, lhsValue) in lhs {
        guard let rhsValue = rhs[key] else {
            return false
        }
        if !areEqual(lhsValue, rhsValue) {
            return false
        }
    }

    return true
}

func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    switch (lhs, rhs) {
    case (let lhs as [String: Any], let rhs as [String: Any]):
        return areEqualDictionaries(lhs, rhs)
    case (let lhs as [Any], let rhs as [Any]):
        return areEqualArrays(lhs, rhs)
    case (let lhs as String, let rhs as String):
        return lhs == rhs
    case (let lhs as Int, let rhs as Int):
        return lhs == rhs
    case (let lhs as Double, let rhs as Double):
        return lhs == rhs
    case (let lhs as Bool, let rhs as Bool):
        return lhs == rhs
    default:
        return false
    }
}

func areEqualArrays(_ lhs: [Any], _ rhs: [Any]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }

    for (index, lhsValue) in lhs.enumerated() {
        if !areEqual(lhsValue, rhs[index]) {
            return false
        }
    }

    return true
}


