//
//  BloodDiastolicObservationConverter.swift
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

struct BloodDiastolicObservationConverter: FHIRObservationConverter {
    let code = "mm[Hg]"
    let unit = "mmHg"

    func convertToObservation(data: Any, aggregationType: AggregationType) -> Observation? {
        if let data = data as? DigiMeHealthKit.Quantity {
            return createObservation(data: data)
        }
        else if let data = data as? DigiMeHealthKit.Statistics {
            return createAggregatedBloodDiastolicObservation(data: data, aggregationType: aggregationType)
        }
        else {
            return nil
        }
    }

    func dataConverterType() -> SampleType {
        return QuantityType.bloodPressureDiastolic
    }

    func getCreatedDate(data: Any) -> Date {
        if let data = data as? DigiMeHealthKit.Quantity {
            return Date(timeIntervalSince1970: data.startTimestamp)
        }
        else if let data = data as? DigiMeHealthKit.Statistics {
            return Date(timeIntervalSince1970: data.startTimestamp)
        }
        else {
            return Date.date(year: 1970, month: 1, day: 1)
        }
    }

    func getFormattedValueString(data: Any) -> String {
        if let quantityData = data as? DigiMeHealthKit.Quantity {
            return "\(quantityData.harmonized.value) \(quantityData.harmonized.unit)"
        }
        else if let data = data as? DigiMeHealthKit.Statistics {
            return "MIN \(Int(round(data.harmonized.min ?? 0))), MAX \(Int(round(data.harmonized.max ?? 0))), AVG \(Int(round(data.harmonized.average ?? 0))) \(data.harmonized.unit)"
        }
        else {
            return "n/a"
        }
    }

    // MARK: - Private

    private func createObservation(data: DigiMeHealthKit.Quantity) -> Observation {
        let coding = ModelsR5.Coding(code: "8462-4", display: "Diastolic Blood Pressure", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Diastolic Blood Pressure")))
        let status = FHIRPrimitive<ObservationStatus>(.final)

        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.id.lowercased())), status: status)

        let valueQuantity = ModelsR5.Quantity()
        valueQuantity.unit = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.code = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.system = FHIRPrimitive(FHIRURI("http://unitsofmeasure.org"))
        valueQuantity.value = FHIRPrimitive(FHIRDecimal(floatLiteral: data.harmonized.value))

        observation.value = Observation.ValueX.quantity(valueQuantity)

        let identifier = Identifier()
        identifier.value = FHIRPrimitive(FHIRString(data.identifier))
        identifier.type?.text = FHIRPrimitive(FHIRString(data.sourceRevision.source.name))
        observation.identifier = [identifier]

        observation.category = [CodeableConcept(coding: [categoryCoding])]

        observation.subject = Reference(display: "Health App Diastolic Blood Pressure Observation", reference: "Patient/healthkit-export")

        let dateString = Date(timeIntervalSince1970: data.startTimestamp).iso8601String
        if let dateTime = try? DateTime(dateString) {
            observation.effective = Observation.EffectiveX.dateTime(FHIRPrimitive(dateTime))
        }
        if let issuedInstant = try? Instant(dateString) {
            observation.issued = FHIRPrimitive(issuedInstant)
        }

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

    private func createAggregatedBloodDiastolicObservation(data: DigiMeHealthKit.Statistics, aggregationType: AggregationType) -> Observation? {
        let minValue = data.harmonized.min ?? 0
        let maxValue = data.harmonized.max ?? 0
        let avgValue = data.harmonized.average ?? 0

        let coding = ModelsR5.Coding(code: "8462-4", display: "Diastolic Blood Pressure", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding])

        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.id.lowercased())), status: FHIRPrimitive(ObservationStatus.final))

        let identifier = Identifier(value: FHIRPrimitive(FHIRString("diastolic-blood-pressure-summary-\(aggregationType.rawValue)-\(data.id.lowercased())")))
        observation.identifier = [identifier]

        observation.category = [CodeableConcept(coding: [categoryCoding])]

        observation.subject = Reference(display: FHIRPrimitive(FHIRString("Health App Diastolic Blood Pressure Observation")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))

        let effectivePeriod = Period(end: FHIRPrimitive(try? DateTime(date: Date(timeIntervalSince1970: data.endTimestamp))), start: FHIRPrimitive(try? DateTime(date: Date(timeIntervalSince1970: data.startTimestamp))))
        observation.effective = .period(effectivePeriod)

        observation.issued = FHIRPrimitive(try? Instant(date: Date()))

        let valueQuantity = Quantity(code: FHIRPrimitive(FHIRString(self.code)), system: FHIRPrimitive(FHIRURI("http://unitsofmeasure.org")), unit: FHIRPrimitive(FHIRString(self.unit)), value: FHIRPrimitive(FHIRDecimal(floatLiteral: avgValue)))
        observation.value = .quantity(valueQuantity)

        let components: [ObservationComponent] = [
            createBloodDiastolicComponent(code: "Minimum Diastolic Blood Pressure", value: minValue),
            createBloodDiastolicComponent(code: "Maximum Diastolic Blood Pressure", value: maxValue),
            createBloodDiastolicComponent(code: "Average Diastolic Blood Pressure", value: avgValue)
        ]

        observation.component = components

        let aggregationText: String
        switch aggregationType {
        case .daily:
            aggregationText = "Daily"
        case .weekly:
            aggregationText = "Weekly"
        case .monthly:
            aggregationText = "Monthly"
        case .yearly:
            aggregationText = "Yearly"
        case .none:
            aggregationText = ""
        }
        code.text = FHIRPrimitive(FHIRString("\(aggregationText) Diastolic Blood Pressure Summary".trimmingCharacters(in: .whitespaces)))

        let profileURL = URL(string: "http://nictiz.nl/fhir/StructureDefinition/zib-BloodPressure")!
        observation.meta = Meta(profile: [FHIRPrimitive(Canonical(profileURL))])

        let performer = Reference(display: FHIRPrimitive(FHIRString("Self-recorded")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))
        observation.performer = [performer]

        return observation
    }

    private func createBloodDiastolicComponent(code: String, value: Double) -> ObservationComponent {
        let coding = Coding(code: FHIRPrimitive(FHIRString("8462-4")), display: FHIRPrimitive(FHIRString("Diastolic Blood Pressure")), system: FHIRPrimitive(FHIRURI("http://loinc.org")))
        let codeableConcept = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString(code)))
        let quantity = Quantity(code: FHIRPrimitive(FHIRString(self.code)), system: FHIRPrimitive(FHIRURI("http://unitsofmeasure.org")), unit: FHIRPrimitive(FHIRString(self.unit)), value: FHIRPrimitive(FHIRDecimal(floatLiteral: value)))

        return ObservationComponent(code: codeableConcept, value: .quantity(quantity))
    }
}
