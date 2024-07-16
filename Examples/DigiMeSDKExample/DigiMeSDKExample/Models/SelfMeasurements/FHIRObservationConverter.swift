//
//  FHIRObservationConverter.swift
//  DigiMeSDKExample
//
//  Created on 28/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeHealthKit
import Foundation
import ModelsR5

protocol FHIRObservationConverter {
    func convertToObservation(data: Any) -> Observation?
    func dataConverterType() -> SampleType
    func getCreatedDate(data: Any) -> Date
    func getFormattedValueString(data: Any) -> String
}