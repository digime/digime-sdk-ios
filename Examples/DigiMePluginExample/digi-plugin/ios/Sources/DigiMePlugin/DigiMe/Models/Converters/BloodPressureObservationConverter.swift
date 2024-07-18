//
//  BloodPressureObservationConverter.swift
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

struct BloodPressureObservationConverter: FHIRObservationConverter {
    var code: String {
        return "mm[Hg]"
    }

    var unit: String {
        return "mmHg"
    }

    func convertToObservation(data: Any) -> Observation? {
        guard let data = data as? Correlation else {
            return nil
        }

        return createObservation(data: data)
    }

    func dataConverterType() -> SampleType {
        return CorrelationType.bloodPressure
    }

    func getCreatedDate(data: Any) -> Date {
        guard let quantityData = data as? Correlation else {
            return Date.date(year: 1970, month: 1, day: 1)
        }

        return Date(timeIntervalSince1970: quantityData.startTimestamp)
    }

    func getFormattedValueString(data: Any) -> String {
        guard
            let quantityData = data as? Correlation,
            quantityData.harmonized.quantitySamples.count == 2,
            let first = quantityData.harmonized.quantitySamples.first(where: { $0.identifier == "HKQuantityTypeIdentifierBloodPressureSystolic" }),
            let second = quantityData.harmonized.quantitySamples.first(where: { $0.identifier == "HKQuantityTypeIdentifierBloodPressureDiastolic" }) else {
            return ""
        }

        return "Sys: \(first.harmonized.value), Dia: \(second.harmonized.value) \(second.harmonized.unit)"
    }

    // MARK: - Private

    private func createObservation(data: Correlation) -> Observation {
        let coding = ModelsR5.Coding(code: "85354-9", display: "Blood pressure panel with all children optional", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Blood Pressure")))
        let status = FHIRPrimitive<ObservationStatus>(.final)

        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.uuid)), status: status)

        if
                data.harmonized.quantitySamples.count == 2,
                let first = data.harmonized.quantitySamples.first(where: { $0.identifier == "HKQuantityTypeIdentifierBloodPressureSystolic" }),
                let second = data.harmonized.quantitySamples.first(where: { $0.identifier == "HKQuantityTypeIdentifierBloodPressureDiastolic" }) {

            let systolicComponent = ObservationComponent(code: CodeableConcept(coding: [ModelsR5.Coding(code: "8480-6", display: "Systolic blood pressure", system: "http://loinc.org")]))

            let valueQuantity1 = ModelsR5.Quantity()
            valueQuantity1.unit = FHIRPrimitive(FHIRString(first.harmonized.unit))
            valueQuantity1.code = FHIRPrimitive(FHIRString(self.code))
            valueQuantity1.system = FHIRPrimitive(FHIRURI("http://unitsofmeasure.org"))
            valueQuantity1.value = FHIRPrimitive(FHIRDecimal(floatLiteral: first.harmonized.value))
            systolicComponent.value = ObservationComponent.ValueX.quantity(valueQuantity1)

            let diastolicComponent = ObservationComponent(code: CodeableConcept(coding: [ModelsR5.Coding(code: "8462-4", display: "Diastolic blood pressure", system: "http://loinc.org")]))
            let valueQuantity2 = ModelsR5.Quantity()
            valueQuantity2.unit = FHIRPrimitive(FHIRString(second.harmonized.unit))
            valueQuantity2.code = FHIRPrimitive(FHIRString(self.code))
            valueQuantity2.system = FHIRPrimitive(FHIRURI("http://unitsofmeasure.org"))
            valueQuantity2.value = FHIRPrimitive(FHIRDecimal(floatLiteral: second.harmonized.value))
            diastolicComponent.value = ObservationComponent.ValueX.quantity(valueQuantity2)
            
            observation.component = [systolicComponent, diastolicComponent]
        }

        // Set the identifier for the observation
        let identifier = Identifier()
        identifier.value = FHIRPrimitive(FHIRString(data.identifier))
        identifier.type?.text = FHIRPrimitive(FHIRString(data.sourceRevision.source.name))
        observation.identifier = [identifier]

        observation.category = [CodeableConcept(coding: [categoryCoding])]

        // Update the subject display for the observation
        observation.subject = Reference(display: "Health App Systolic Blood Pressure Observation", reference: "Patient/healthkit-export")

        let dateString = Date(timeIntervalSince1970: data.startTimestamp).iso8601String
        if let dateTime = try? DateTime(dateString) {
            observation.effective = Observation.EffectiveX.dateTime(FHIRPrimitive(dateTime))
        }
        if let issuedInstant = try? Instant(dateString) {
            observation.issued = FHIRPrimitive(issuedInstant)
        }

        // Set the device information for the observation
        let deviceReference = Reference()
        deviceReference.display = FHIRPrimitive(FHIRString(data.sourceRevision.productType ?? "iOS Device"))
        deviceReference.reference = FHIRPrimitive(FHIRString(data.sourceRevision.source.bundleIdentifier))
        observation.device = deviceReference

        let profileURL = URL(string: "http://nictiz.nl/fhir/StructureDefinition/zib-BloodPressure")!
        observation.meta = Meta(profile: [FHIRPrimitive(Canonical(profileURL))])

        let performer = Reference(display: FHIRPrimitive(FHIRString("Self-recorded")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))
        observation.performer = [performer]
        
        return observation
    }
}
