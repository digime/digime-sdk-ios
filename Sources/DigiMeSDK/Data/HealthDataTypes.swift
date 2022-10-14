//
//  HealthDataTypes.swift
//  DigiMeSDK
//
//  Created on 02/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import HealthKit

enum HealthDataTypes {
    static var readDataTypes: [HKSampleType] {
        return dataTypes
    }
    
    static var shareDataTypes: [HKSampleType] {
        var typeIdentifiers = [String]()
        typeIdentifiers.append(contentsOf: FitnessActivityProcessor.dataTypesWrite)
        return typeIdentifiers.compactMap { HKSampleType.getSampleType(for: $0) }
    }
    
    static var dataTypes: [HKSampleType] {
        return allHealthDataTypeIDs.compactMap { HKSampleType.getSampleType(for: $0) }
    }
    
    private static var allHealthDataTypeIDs: [String] {
        var typeIdentifiers = [String]()
        typeIdentifiers.append(contentsOf: FitnessActivityProcessor.dataTypesRead)
        return typeIdentifiers
    }
}
