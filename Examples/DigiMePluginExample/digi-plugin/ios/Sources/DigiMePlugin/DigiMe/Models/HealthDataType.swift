//
//  HealthDataType.swift
//  DigiMeSDKExample
//
//  Created on 02/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeHealthKit
import Foundation
import SwiftUI

class HealthDataType: Identifiable, ObservableObject {
    let id: UUID
    var type: SampleType
    @Published var isToggled: Bool

    init(type: SampleType, isToggled: Bool = true) {
        self.id = UUID()
        self.type = type
        self.isToggled = isToggled
    }

    init?(typeIdentifier: String, isToggled: Bool = true) {
        guard let type = HealthDataType.getTypeById(typeIdentifier) else {
            return nil
        }
        self.id = UUID()
        self.type = type
        self.isToggled = isToggled
    }

    var name: String {
        if let type = type as? QuantityType {
            return getQuantityName(type: type)
        }
        else if let type = type as? CorrelationType {
            return getCorrelationName(type: type)
        }
        else {
            return ""
        }
    }

    var systemIcon: String {
        if let type = type as? QuantityType {
            return getQuantityIconName(type: type)
        }
        else if let type = type as? CorrelationType {
            return getCorrelationIconName(type: type)
        }
        else {
            return ""
        }
    }

    var iconColor: Color? {
        if let type = type as? QuantityType {
            return getQuantityIconColor(type: type)
        }
        else if let type = type as? CorrelationType {
            return getCorrelationIconColor(type: type)
        }
        else {
            return nil
        }
    }

    // MARK: - Quantity

    private func getQuantityName(type: QuantityType) -> String {
        switch type {
        case .bodyMass:
            return "weight".localized()
        case .height:
            return "height".localized()
        case .bodyTemperature:
            return "bodyTemperature".localized()
        case .oxygenSaturation:
            return "bloodOxygen".localized()
        case .respiratoryRate:
            return "respiratoryRate".localized()
        case .heartRate:
            return "heartRate".localized()
        case .bloodPressureSystolic:
            return "systolicBloodPressure".localized()
        case .bloodPressureDiastolic:
            return "diastolicBloodPressure".localized()
        case .bloodGlucose:
            return "bloodGlucose".localized()
        default:
            return ""
        }
    }

    private func getQuantityIconName(type: QuantityType) -> String {
        switch type {
        case .bodyMass:
            return "figure"
        case .height:
            return "figure"
        case .bodyTemperature:
            return "waveform.path.ecg.rectangle"
        case .oxygenSaturation:
            return "lungs.fill"
        case .respiratoryRate:
            return "lungs.fill"
        case .heartRate:
            return "heart.fill"
        case .bloodPressureSystolic:
            return "heart.fill"
        case .bloodPressureDiastolic:
            return "heart.fill"
        case .bloodGlucose:
            return "waveform.path.ecg.rectangle"
        default:
            return ""
        }
    }

    private func getQuantityIconColor(type: QuantityType) -> Color? {
        switch type {
        case .bodyMass:
            return .purple
        case .height:
            return .purple
        case .heartRate:
            return .red
        case .bloodPressureSystolic:
            return .red
        case .bloodPressureDiastolic:
            return .red
        default:
            return nil
        }
    }

    // MARK: - Correlation

    private func getCorrelationName(type: CorrelationType) -> String {
        switch type {
        case .bloodPressure:
            return "Blood Pressure"
        default:
            return ""
        }
    }

    private func getCorrelationIconName(type: CorrelationType) -> String {
        switch type {
        case .bloodPressure:
            return "heart.fill"
        default:
            return ""
        }
    }

    private func getCorrelationIconColor(type: CorrelationType) -> Color? {
        switch type {
        case .bloodPressure:
            return .red
        default:
            return nil
        }
    }
}

extension HealthDataType {
    static func getTypeById(_ identifier: String) -> SampleType? {
        switch identifier {
        case "HKQuantityTypeIdentifierBodyMass":
            return QuantityType.bodyMass
        case "HKQuantityTypeIdentifierHeight":
            return QuantityType.height
        case "HKQuantityTypeIdentifierBodyTemperature":
            return QuantityType.bodyTemperature
        case "HKQuantityTypeIdentifierOxygenSaturation":
            return QuantityType.oxygenSaturation
        case "HKQuantityTypeIdentifierRespiratoryRate":
            return QuantityType.respiratoryRate
        case "HKQuantityTypeIdentifierHeartRate":
            return QuantityType.heartRate
        case "HKQuantityTypeIdentifierBloodPressureSystolic":
            return QuantityType.bloodPressureSystolic
        case "HKQuantityTypeIdentifierBloodPressureDiastolic":
            return QuantityType.bloodPressureDiastolic
        case "HKQuantityTypeIdentifierBloodGlucose":
            return QuantityType.bloodGlucose
        case "HKCorrelationTypeIdentifierBloodPressure":
            return CorrelationType.bloodPressure

        default:
            return nil
        }
    }

    static func getIdByType(_ inputType: SampleType) -> String? {
        if let inputType = inputType as? QuantityType {
            return inputType.identifier
        }
        else if let inputType = inputType as? CorrelationType {
            return inputType.identifier
        }
        else {
            return nil
        }
    }
}

extension HealthDataType: Comparable {
    static func < (lhs: HealthDataType, rhs: HealthDataType) -> Bool {
        return lhs.type.identifier == rhs.type.identifier
    }
}

extension HealthDataType: Equatable {
    static func == (lhs: HealthDataType, rhs: HealthDataType) -> Bool {
        return lhs.type.identifier == rhs.type.identifier
    }
}

extension HealthDataType: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
