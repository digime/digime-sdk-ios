//
//  TemperatureObservationConverter.swift
//  DigiMeSDKExample
//
//  Created on 28/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import Foundation
import ModelsR5
import UIKit

struct TemperatureObservationConverter: FHIRObservationConverter {
    var code: String {
        return "Cel"
    }

    var unit: String {
        return "degC"
    }

    func convertToObservation(data: Any) -> Observation? {
        guard let quantityData = data as? DigiMeHealthKit.Quantity else {
            return nil
        }
        
        return createObservation(data: quantityData)
    }

    func dataConverterType() -> SampleType {
        return QuantityType.bodyTemperature
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

    private func createObservation(data: DigiMeHealthKit.Quantity) -> Observation {
        let coding = ModelsR5.Coding(code: "8310-5", display: "Body Temperature", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Body Temperature")))
        let status = FHIRPrimitive<ObservationStatus>(.final)
        
        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.uuid)), status: status)
        
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
        
        // Set the subject of the observation
        observation.subject = Reference(display: "Health App Body Temperature Observation", reference: "Patient/healthkit-export")
        
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
        
        let profileURL = URL(string: "http://nictiz.nl/fhir/StructureDefinition/zib-BodyTemperature")!
        observation.meta = Meta(profile: [FHIRPrimitive(Canonical(profileURL))])

        let performer = Reference(display: FHIRPrimitive(FHIRString("Self-recorded")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))
        observation.performer = [performer]

        return observation
    }
}
