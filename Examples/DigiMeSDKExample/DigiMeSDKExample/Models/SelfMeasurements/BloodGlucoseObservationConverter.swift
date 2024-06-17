//
//  BloodGlucoseObservationConverter.swift
//  DigiMeSDKExample
//
//  Created on 29/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import Foundation
import ModelsR5
import UIKit

struct BloodGlucoseObservationConverter: FHIRObservationConverter {
    func convertToObservation(data: Any) -> Observation? {
        guard let quantityData = data as? DigiMeHealthKit.Quantity else {
            return nil
        }

        return createObservation(data: quantityData)
    }

    func dataConverterType() -> SampleType {
        return QuantityType.bloodGlucose
    }

    func getCreatedDate(data: Any) -> Date {
        guard let quantityData = data as? DigiMeHealthKit.Quantity else {
            return Date.date(year: 1970, month: 1, day: 1)
        }

        return Date(timeIntervalSince1970: quantityData.startTimestamp)
    }

    func getFormattedValueString(data: Any) -> String {
        guard let quantityData = data as? DigiMeHealthKit.Quantity else {
            return "n/a"
        }

        return "\(quantityData.harmonized.value) \(quantityData.harmonized.unit)"
    }

    // MARK: - Private

    private func createObservation(data: DigiMeHealthKit.Quantity) -> ModelsR5.Observation {
        // Updated coding for Blood Glucose
        let coding = ModelsR5.Coding(code: "2339-0", display: "Blood Glucose", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "laboratory", display: "Laboratory", system: "http://terminology.hl7.org/CodeSystem/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Blood Glucose")))
        let status = FHIRPrimitive<ObservationStatus>(.final)

        let observation = ModelsR5.Observation(code: code, id: FHIRPrimitive(FHIRString(data.uuid)), status: status)

        // Create the quantity for the observation value
        let valueQuantity = Quantity()
        valueQuantity.unit = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.code = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.system = FHIRPrimitive(FHIRURI("http://unitsofmeasure.org"))
        valueQuantity.value = FHIRPrimitive(FHIRDecimal(floatLiteral: data.harmonized.value))

        observation.value = Observation.ValueX.quantity(valueQuantity)

        // Set the identifier for the observation
        let identifier = Identifier()
        identifier.value = FHIRPrimitive(FHIRString(data.identifier))
        identifier.type?.text = FHIRPrimitive(FHIRString(data.sourceRevision.source.name))
        observation.identifier = [identifier]

        observation.category = [CodeableConcept(coding: [categoryCoding])]

        // Update the subject display for the observation
        observation.subject = Reference(display: "Health App Blood Glucose Observation", reference: "Patient/healthkit-export")

        let dateString = Date(timeIntervalSince1970: data.startTimestamp).iso8601String
        if let dateTime = try? DateTime(dateString) {
            observation.effective = ModelsR5.Observation.EffectiveX.dateTime(FHIRPrimitive(dateTime))
        }
        if let issuedInstant = try? Instant(dateString) {
            observation.issued = FHIRPrimitive(issuedInstant)
        }

        // Set the device information for the observation
        let deviceReference = Reference()
        deviceReference.display = FHIRPrimitive(FHIRString(data.sourceRevision.productType ?? "iOS Device"))
        deviceReference.reference = FHIRPrimitive(FHIRString(data.sourceRevision.source.bundleIdentifier))
        deviceReference.type = FHIRPrimitive(FHIRURI("http://hl7.org/fhir/StructureDefinition/Device"))

        let deviceId = Identifier()
        deviceId.type = CodeableConcept(text: FHIRPrimitive(FHIRString("version")))
        deviceId.value = FHIRPrimitive(FHIRString(data.sourceRevision.systemVersion))

        deviceReference.identifier = deviceId
        observation.device = deviceReference

        return observation
    }
}
