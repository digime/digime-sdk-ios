//
//  BodyMassObservationConverter.swift
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

struct BodyMassObservationConverter: FHIRObservationConverter {
    var code: String {
        return "kg"
    }

    var unit: String {
        return "kg"
    }

    func convertToObservation(data: Any) -> Observation? {
        guard let quantityData = data as? DigiMeHealthKit.Quantity else {
            return nil
        }

        return createObservation(data: quantityData)
    }

    func dataConverterType() -> SampleType {
        return QuantityType.bodyMass
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
        let coding = ModelsR5.Coding(code: "29463-7", display: "Body Weight", system: "http://loinc.org")
        let categoryCoding = ModelsR5.Coding(code: "vital-signs", display: "Vital Signs", system: "http://hl7.org/fhir/observation-category")
        let code = CodeableConcept(coding: [coding], text: FHIRPrimitive(FHIRString("Body Weight")))
        let status = FHIRPrimitive<ObservationStatus>(.final)
        let observation = Observation(code: code, id: FHIRPrimitive(FHIRString(data.uuid)), status: status)
        let valueQuantity = ModelsR5.Quantity()
        valueQuantity.unit = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.code = FHIRPrimitive(FHIRString(data.harmonized.unit))
        valueQuantity.system = FHIRPrimitive(FHIRURI("http://unitsofmeasure.org"))
        valueQuantity.value = FHIRPrimitive(FHIRDecimal(floatLiteral: data.harmonized.value))
        let observationValue = Observation.ValueX.quantity(valueQuantity)
        observation.value = observationValue
        let identifier = Identifier()
        identifier.value = FHIRPrimitive(FHIRString(data.identifier))
        identifier.type?.text = FHIRPrimitive(FHIRString(data.sourceRevision.source.name))
        observation.identifier = [identifier]
        observation.category = [CodeableConcept(coding: [categoryCoding])]
        observation.subject = Reference(display: "Health App Body Weight Observation", reference: "Patient/healthkit-export")

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

        let performer = Reference(display: FHIRPrimitive(FHIRString("Self-recorded")), reference: FHIRPrimitive(FHIRString("Patient/healthkit-export")))
        observation.performer = [performer]

        let profileURL = URL(string: "http://nictiz.nl/fhir/StructureDefinition/zib-BodyWeight")!
        observation.meta = Meta(profile: [FHIRPrimitive(Canonical(profileURL))])

        return observation
    }

    private func createDevice(data: DigiMeHealthKit.Quantity) -> ModelsR5.Device {
        let device = ModelsR5.Device()
        device.id = FHIRPrimitive(FHIRString(UIDevice.current.identifierForVendor!.uuidString))
        device.modelNumber = FHIRPrimitive(FHIRString(data.sourceRevision.productType ?? "iPhone"))
        device.manufacturer = FHIRPrimitive(FHIRString("Apple"))
        device.lotNumber = FHIRPrimitive(FHIRString(data.sourceRevision.source.bundleIdentifier))
        device.version = [DeviceVersion(value: FHIRPrimitive(FHIRString(data.sourceRevision.systemVersion)))]
        return device
    }
}
