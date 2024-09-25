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
    let code = "mm[Hg]"
    let unit = "mmHg"

    func convertToObservation(data: Any, aggregationType: AggregationType) -> Observation? {
        if let data = data as? Correlation {
            return createObservation(data: data)
        }
        else if let data = data as? CombinedBloodPressureStats {
            return createAggregatedBloodPressureObservation(data: data, aggregationType: aggregationType)
        }
        else {
            return nil
        }
    }

    func dataConverterType() -> SampleType {
        return CorrelationType.bloodPressure
    }

    func getCreatedDate(data: Any) -> Date {
        if let correlation = data as? Correlation {
            return Date(timeIntervalSince1970: correlation.startTimestamp)
        } 
        else if let combinedStats = data as? CombinedBloodPressureStats {
            return combinedStats.startDate
        }
        return Date.date(year: 1970, month: 1, day: 1)
    }

    func getFormattedValueString(data: Any) -> String {
        if let correlation = data as? Correlation,
           let systolic = correlation.harmonized.quantitySamples.first(where: { $0.identifier == "HKQuantityTypeIdentifierBloodPressureSystolic" }),
           let diastolic = correlation.harmonized.quantitySamples.first(where: { $0.identifier == "HKQuantityTypeIdentifierBloodPressureDiastolic" }) {
            return "Sys: \(systolic.harmonized.value), Dia: \(diastolic.harmonized.value) \(systolic.harmonized.unit)"
        } 
        else if let combinedStats = data as? CombinedBloodPressureStats {
            let systolicAvg = combinedStats.systolic.harmonized.average ?? 0
            let diastolicAvg = combinedStats.diastolic.harmonized.average ?? 0
            return "Sys: \(systolicAvg), Dia: \(diastolicAvg) \(self.unit)"
        }
        return "n/a"
    }

    // MARK: - Private

    private func createObservation(data: Correlation) -> Observation {
        let coding = ModelsR5.Coding(code: "85354-9", display: "Blood pressure panel with all children optional", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Blood Pressure")))
        let status = FHIRPrimitive<ObservationStatus>(.final)
        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.id.lowercased())), status: status)

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

    private func createAggregatedBloodPressureObservation(data: CombinedBloodPressureStats, aggregationType: AggregationType) -> Observation? {
        let coding = Coding(code: FHIRPrimitive(FHIRString("85354-9")), display: FHIRPrimitive(FHIRString("Blood pressure panel with all children optional")), system: FHIRPrimitive(FHIRURI("http://loinc.org")))
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Blood Pressure")))

        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.id.lowercased())), status: FHIRPrimitive(ObservationStatus.final))

        let identifier = Identifier(value: FHIRPrimitive(FHIRString("blood-pressure-summary-\(aggregationType.rawValue)-\(UUID().uuidString.lowercased())")))
        observation.identifier = [identifier]

        let categoryCoding = Coding(code: FHIRPrimitive(FHIRString("vital-signs")), display: FHIRPrimitive(FHIRString("Vital Signs")), system: FHIRPrimitive(FHIRURI("http://terminology.hl7.org/CodeSystem/observation-category")))
        observation.category = [CodeableConcept(coding: [categoryCoding])]

        observation.subject = Reference(display: FHIRPrimitive(FHIRString("Health App Blood Pressure Observation")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))

        let effectivePeriod = Period(end: FHIRPrimitive(try? DateTime(date: data.endDate)), start: FHIRPrimitive(try? DateTime(date: data.startDate)))
        observation.effective = .period(effectivePeriod)

        observation.issued = FHIRPrimitive(try? Instant(date: Date()))

        let systolicComponent = createBloodPressureComponent(
            code: "8480-6",
            display: "Systolic blood pressure",
            stats: data.systolic,
            identifier: "HKQuantityTypeIdentifierBloodPressureSystolic"
        )
        let diastolicComponent = createBloodPressureComponent(
            code: "8462-4",
            display: "Diastolic blood pressure",
            stats: data.diastolic,
            identifier: "HKQuantityTypeIdentifierBloodPressureDiastolic"
        )

        observation.component = [systolicComponent, diastolicComponent]

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
        code.text = FHIRPrimitive(FHIRString("\(aggregationText) Blood Pressure Summary".trimmingCharacters(in: .whitespaces)))

        let deviceReference = Reference(display: FHIRPrimitive(FHIRString("iOS Device")), reference: FHIRPrimitive(FHIRString("Device/healthkit-device")))
        observation.device = deviceReference

        let profileURL = URL(string: "http://nictiz.nl/fhir/StructureDefinition/zib-BloodPressure")!
        observation.meta = Meta(profile: [FHIRPrimitive(Canonical(profileURL))])

        let performer = Reference(display: FHIRPrimitive(FHIRString("Self-recorded")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))
        observation.performer = [performer]

        return observation
    }

    private func createBloodPressureComponent(code: String, display: String, stats: DigiMeHealthKit.Statistics, identifier: String) -> ObservationComponent {
        let coding = Coding(code: FHIRPrimitive(FHIRString(code)), display: FHIRPrimitive(FHIRString(display)), system: FHIRPrimitive(FHIRURI("http://loinc.org")))
        let codeableConcept = CodeableConcept(coding: [coding])

        guard let avgValue = stats.harmonized.average else {
            fatalError("Missing required blood pressure data")
        }

        let avgQuantity = Quantity(code: FHIRPrimitive(FHIRString(self.code)), system: FHIRPrimitive(FHIRURI("http://unitsofmeasure.org")), unit: FHIRPrimitive(FHIRString(self.unit)), value: FHIRPrimitive(FHIRDecimal(floatLiteral: avgValue)))

        let component = ObservationComponent(code: codeableConcept, value: .quantity(avgQuantity))

        if let minValue = stats.harmonized.min {
            let minExtension = Extension(url: FHIRPrimitive(FHIRURI("http://hl7.org/fhir/StructureDefinition/observation-min")))
            minExtension.value = .quantity(Quantity(value: FHIRPrimitive(FHIRDecimal(floatLiteral: minValue))))
            component.extension = [minExtension]
        }

        if let maxValue = stats.harmonized.max {
            let maxExtension = Extension(url: FHIRPrimitive(FHIRURI("http://hl7.org/fhir/StructureDefinition/observation-max")))
            maxExtension.value = .quantity(Quantity(value: FHIRPrimitive(FHIRDecimal(floatLiteral: maxValue))))
            component.extension = (component.extension ?? []) + [maxExtension]
        }

        return component
    }
}
