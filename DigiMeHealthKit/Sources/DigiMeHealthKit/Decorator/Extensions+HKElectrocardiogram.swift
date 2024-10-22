//
//  Extensions+HKElectrocardiogram.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import HealthKit

@available(iOS 14.0, *)
extension HKElectrocardiogram {
    typealias Harmonized = Electrocardiogram.Harmonized

	func harmonize(voltageMeasurements: [Electrocardiogram.VoltageMeasurement]) throws -> Harmonized {
		let averageHeartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
		let averageHeartRate = averageHeartRate?.doubleValue(for: averageHeartRateUnit)
		let samplingFrequencyUnit = HKUnit.hertz()
		guard
			let samplingFrequency = samplingFrequency?.doubleValue(for: samplingFrequencyUnit)
		else {
			throw SDKError.invalidValue(
				message: "Invalid samplingFrequency value for HKElectrocardiogram"
			)
		}
		return Harmonized(averageHeartRate: averageHeartRate,
						  averageHeartRateUnit: averageHeartRateUnit.unitString,
						  samplingFrequency: samplingFrequency,
						  samplingFrequencyUnit: samplingFrequencyUnit.unitString,
						  classification: classification.description,
						  symptomsStatus: symptomsStatus.description,
						  count: numberOfVoltageMeasurements,
						  voltageMeasurements: voltageMeasurements,
						  metadata: metadata?.asMetadata)
	}
}

@available(iOS 14.0, *)
extension HKElectrocardiogram.VoltageMeasurement: Harmonizable {
    typealias Harmonized = Electrocardiogram.VoltageMeasurement.Harmonized

    func harmonize() throws -> Harmonized {
        guard
            let quantitiy = quantity(for: .appleWatchSimilarToLeadI)
        else {
            throw SDKError.invalidValue(
				message: "Invalid averageHeartRate value for HKElectrocardiogram"
            )
        }
        let unit = HKUnit.volt()
        let voltage = quantitiy.doubleValue(for: unit)
        return Harmonized(value: voltage, unit: unit.unitString)
    }
}

// MARK: - CustomStringConvertible

@available(iOS 14.0, *)
extension HKElectrocardiogram.Classification {
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .sinusRhythm:
            return "Sinus rhytm"
        case .atrialFibrillation:
            return "Atrial fibrillation"
        case .inconclusiveLowHeartRate:
            return "Inconclusive low heart rate"
        case .inconclusiveHighHeartRate:
            return "Inconclusive high heart rate"
        case .inconclusivePoorReading:
            return "Inconclusive poor reading"
        case .inconclusiveOther:
            return "Inconclusive other"
        case .unrecognized:
            return "Unrecognized"
        @unknown default:
            fatalError()
        }
    }
}

// MARK: - CustomStringConvertible

@available(iOS 14.0, *)
extension HKElectrocardiogram.SymptomsStatus {
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .none:
            return "None"
        case .present:
            return "Present"
        @unknown default:
            fatalError()
        }
    }
}
