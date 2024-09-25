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
    var code: String { get }
    var unit: String { get }
    func convertToObservation(data: Any, aggregationType: AggregationType) -> Observation?
    func dataConverterType() -> SampleType
    func getCreatedDate(data: Any) -> Date
    func getFormattedValueString(data: Any) -> String
}
