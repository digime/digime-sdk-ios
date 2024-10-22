//
//  Extensions+HKVisionPrescription.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
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
