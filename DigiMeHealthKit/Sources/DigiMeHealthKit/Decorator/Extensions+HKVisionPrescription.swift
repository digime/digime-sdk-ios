//
//  Extensions+HKVisionPrescription.swift
//  DigiMeSDK
//
//  Created on 04.10.22.
//

import HealthKit

@available(iOS 16.0, *)
extension HKVisionPrescription: Harmonizable {
    typealias Harmonized = VisionPrescription.Harmonized

	func harmonize() throws -> VisionPrescription.Harmonized {
		return VisionPrescription.Harmonized(dateIssuedTimestamp: dateIssued.millisecondsSince1970,
											 expirationDateTimestamp: expirationDate?.millisecondsSince1970,
											 prescriptionType: VisionPrescription.PrescriptionType(prescriptionType: prescriptionType),
											 metadata: metadata?.asMetadata)
	}
}
