//
//  SelfMeasurementComponent.swift
//  DigiMeSDKExample
//
//  Created on 30/08/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

@Model
class SelfMeasurementComponent: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case id, measurementValue, unit, unitCode, display
    }
    
    var id: UUID
    var measurementValue: Decimal
    var unit: String
    var unitCode: String
    var display: String

    init(measurementValue: Decimal, unit: String, unitCode: String, display: String) {
        self.id = UUID()
        self.measurementValue = measurementValue
        self.unit = unit
        self.unitCode = unitCode
        self.display = display
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        measurementValue = try container.decode(Decimal.self, forKey: .measurementValue)
        unit = try container.decode(String.self, forKey: .unit)
        unitCode = try container.decode(String.self, forKey: .unitCode)
        display = try container.decode(String.self, forKey: .display)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(measurementValue, forKey: .measurementValue)
        try container.encode(unit, forKey: .unit)
        try container.encode(unitCode, forKey: .unitCode)
        try container.encode(display, forKey: .display)
    }
}

extension SelfMeasurementComponent: Identifiable {
    static func == (lhs: SelfMeasurementComponent, rhs: SelfMeasurementComponent) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SelfMeasurementComponent: Comparable {
    static func < (lhs: SelfMeasurementComponent, rhs: SelfMeasurementComponent) -> Bool {
        return lhs == rhs
    }
}
