//
//  HeartRateObservationConverter.swift
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

struct HeartRateObservationConverter: FHIRObservationConverter {
    let code = "/min"
    let unit = "count/min"

    func convertToObservation(data: Any, aggregationType: AggregationType) -> Observation? {
        if let data = data as? DigiMeHealthKit.Quantity {
            return createObservation(data: data)
        }
        else if let data = data as? DigiMeHealthKit.Statistics {
            return createAggregatedHeartRateObservation(data: data, aggregationType: aggregationType)
        }
        else {
            return nil
        }
    }

    func dataConverterType() -> SampleType {
        return QuantityType.heartRate
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
        // Updated coding for Heart Rate
        let coding = ModelsR5.Coding(code: "8867-4", display: "Heart Rate", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Heart Rate")))
        let status = FHIRPrimitive<ObservationStatus>(.final)

        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.id.lowercased())), status: status)

        // Create the quantity for the observation value
        let valueQuantity = ModelsR5.Quantity()
        valueQuantity.unit = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.code = FHIRPrimitive(FHIRString(self.code))
        valueQuantity.system = FHIRPrimitive(FHIRURI("http://unitsofmeasure.org"))
        valueQuantity.value = FHIRPrimitive(FHIRDecimal(floatLiteral: data.harmonized.value))

        observation.value = Observation.ValueX.quantity(valueQuantity)

        // Set the identifier for the observation
        let identifier = Identifier()
        identifier.value = FHIRPrimitive(FHIRString(data.identifier))
        identifier.type?.text = FHIRPrimitive(FHIRString(data.sourceRevision.source.name))
        observation.identifier = [identifier]

        observation.category = [CodeableConcept(coding: [categoryCoding])]
        observation.subject = Reference(display: "Health App Heart Rate Observation", reference: "Patient/healthkit-export")

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

        let profileURL = URL(string: "http://nictiz.nl/fhir/StructureDefinition/zib-HeartRate")!
        observation.meta = Meta(profile: [FHIRPrimitive(Canonical(profileURL))])

        let performer = Reference(display: FHIRPrimitive(FHIRString("Self-recorded")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))
        observation.performer = [performer]
        
        return observation
    }

    private func createAggregatedHeartRateObservation(data: DigiMeHealthKit.Statistics, aggregationType: AggregationType) -> Observation? {
        let minValue = data.harmonized.min ?? 0
        let maxValue = data.harmonized.max ?? 0
        let avgValue = data.harmonized.average ?? 0

        let coding = Coding(code: FHIRPrimitive(FHIRString("8867-4")), display: FHIRPrimitive(FHIRString("Heart rate")), system: FHIRPrimitive(FHIRURI("http://loinc.org")))
        let code = CodeableConcept(coding: [coding])

        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.id.lowercased())), status: FHIRPrimitive(ObservationStatus.final))

        let identifier = Identifier(value: FHIRPrimitive(FHIRString("heart-rate-summary-\(aggregationType.rawValue)-\(data.id.lowercased())")))
        observation.identifier = [identifier]

        let categoryCoding = Coding(code: FHIRPrimitive(FHIRString("vital-signs")), display: FHIRPrimitive(FHIRString("Vital Signs")), system: FHIRPrimitive(FHIRURI("http://terminology.hl7.org/CodeSystem/observation-category")))
        observation.category = [CodeableConcept(coding: [categoryCoding])]

        observation.subject = Reference(display: "Health App Heart Rate Observation", reference: "Patient/healthkit-export")

        let effectivePeriod = Period(end: FHIRPrimitive(try? DateTime(date: Date(timeIntervalSince1970: data.endTimestamp))), start: FHIRPrimitive(try? DateTime(date: Date(timeIntervalSince1970: data.startTimestamp))))
        observation.effective = .period(effectivePeriod)

        observation.issued = FHIRPrimitive(try? Instant(date: Date()))

        let valueQuantity = Quantity(code: FHIRPrimitive(FHIRString(self.code)), system: FHIRPrimitive(FHIRURI("http://unitsofmeasure.org")), unit: FHIRPrimitive(FHIRString(self.unit)), value: FHIRPrimitive(FHIRDecimal(floatLiteral: avgValue)))
        observation.value = .quantity(valueQuantity)

        let components: [ObservationComponent] = [
            createHeartRateComponent(code: "Minimum Heart Rate", value: minValue),
            createHeartRateComponent(code: "Maximum Heart Rate", value: maxValue),
            createHeartRateComponent(code: "Average Heart Rate", value: avgValue)
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
        code.text = FHIRPrimitive(FHIRString("\(aggregationText) Heart Rate Summary".trimmingCharacters(in: .whitespaces)))

        return observation
    }

    private func createHeartRateComponent(code: String, value: Double) -> ObservationComponent {
        let coding = Coding(code: FHIRPrimitive(FHIRString("8867-4")), display: FHIRPrimitive(FHIRString("Heart rate")), system: FHIRPrimitive(FHIRURI("http://loinc.org")))
        let codeableConcept = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString(code)))
        let quantity = Quantity(code: FHIRPrimitive(FHIRString(self.code)), system: FHIRPrimitive(FHIRURI("http://unitsofmeasure.org")), unit: FHIRPrimitive(FHIRString(self.unit)), value: FHIRPrimitive(FHIRDecimal(floatLiteral: value)))

        return ObservationComponent(code: codeableConcept, value: .quantity(quantity))
    }
}
