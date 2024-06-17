//
//  SelfMeasurement.swift
//  DigiMeSDKExample
//
//  Created on 30/06/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

@Model
class SelfMeasurement: Codable, Hashable {
    var id: UUID
    var name: String
    var type: SelfMeasurementType
    var createdDate: Date
    var components: [SelfMeasurementComponent]
    var comment: String?
    var commentName: String?
    var commentCode: String?
    var commentTiming: String?
    var receipts: [SelfMeasurementReceipt]

    var fhirObservation: ObservationResource {
        return ObservationResource(
            identifier: identifier,
            category: category,
            resourceType: "Observation",
            status: "final",
            code: code,
            effectiveDateTime: effectiveDateTime,
            subject: subject,
            performer: performer,
            valueQuantity: valueQuantity,
            extension: fhirObservationExtension,
            component: resourceComponents,
            method: method,
            interpretation: interpretation,
            comment: comment,
            bodySite: bodySite,

            _gender: nil,
            name: nil,
            birthDate: nil,
            text: nil,
            address: nil,
            gender: nil,
            meta: meta,
            fullUrl: nil
        )
    }
    
    var fullUrl: String {
        return "urn:uuid:\(id.uuidString.lowercased())"
    }

    private var meta: ObservationMeta {
        return ObservationMeta(profile: ["http://hl7.org/fhir/StructureDefinition/Observation"])
    }
                          
    private var identifier: [ObservationIdentifier] {
        return [ObservationIdentifier(value: "\(id.uuidString.lowercased())", system: "https://digi.me/fhir/identification")]
    }
    
    private var category: [ObservationCategory] {
        return [ObservationCategory(coding: [Coding(system: "http://terminology.hl7.org/CodeSystem/observation-category", code: "vital-signs", display: "Vital Signs")])]
    }
    
    private var code: Code {
        switch type {
        case .bloodGlucose:
            return Code(
                coding: [Coding(system: "http://loinc.org", code: commentCode ?? "", display: commentName ?? "")]
            )
        default:
            return Code(
                coding: [Coding(system: "http://loinc.org", code: type.loincCode, display: type.display)]
            )
        }
    }
    
    private var effectiveDateTime: String {
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: createdDate)

        // Check if the time is 00:00
        if components.hour == 0 && components.minute == 0 {
            formatter.formatOptions = [.withFullDate]
        }

        return formatter.string(from: createdDate)
    }
    
    private var subject: ReferenceObject {
        return ReferenceObject(reference: "urn:uuid:\(UserPreferences.shared().selfMeasurementPersonId.lowercased())", display: "Marieke XXX_Bergzoon")
    }
    
    private var performer: [ReferenceObject] {
        return [ReferenceObject(reference: "urn:uuid:\(UserPreferences.shared().selfMeasurementPersonId.lowercased())", display: "Marieke XXX_Bergzoon")]
    }
    
    private var method: Code? {
        switch type {
        case .heartRate:
            return Code(
                coding: [Coding(system: "http://snomed.info/sct", code: "113011001", display: "Palpatie")]
            )
        case .bloodPressure:
            return Code(
                coding: [Coding(system: "http://snomed.info/sct", code: "22762002", display: "Non-invasief")]
            )
        default:
            return nil
        }
    }
    
    private var interpretation: Code? {
        switch type {
        case .heartRate:
            return Code(
                coding: [Coding(system: "http://snomed.info/sct", code: "271636001", display: "Regelmatige polsslag")]
            )
        default:
            return nil
        }
    }
    
    private var resourceComponents: [ResourceComponent]? {
        switch type {
        case .weight:
            let concept1 = ValueCodeableConcept(coding: [Coding(system: "urn:oid:2.16.840.1.113883.2.4.3.11.60.40.4.8.1", code: "UNDRESSED", display: "Zonder kleding.")])
            let rcCode1 = Code(coding: [Coding(system: "http://loinc.org", code: "8352-7", display: "Clothing worn during measure")])
            return [ResourceComponent(valueQuantity: nil, valueCodeableConcept: concept1, code: rcCode1)]
            
        case .bloodPressure:
            var comp: [ResourceComponent] = []
            components.forEach { smComponent in
                if smComponent.display == "Sys (mmHG)" {
                    let coding = Coding(system: "http://loinc.org", code: "8480-6", display: "Intravasculaire systolische bloeddruk [druk] in arterieel vaatstelsel")
                    let valueQuantity = ValueQuantity(value: smComponent.measurementValue, unit: smComponent.unit, code: smComponent.unitCode, system: "http://unitsofmeasure.org")
                    comp.append(ResourceComponent(valueQuantity: valueQuantity, valueCodeableConcept: nil, code: Code(coding: [coding])))
                }
                else if smComponent.display == "Dia (mmHG)" {
                    let coding = Coding(system: "http://loinc.org", code: "8462-4", display: "Intravasculaire diastolische bloeddruk [druk] in arterieel vaatstelsel")
                    let valueQuantity = ValueQuantity(value: smComponent.measurementValue, unit: smComponent.unit, code: smComponent.unitCode, system: "http://unitsofmeasure.org")
                    comp.append(ResourceComponent(valueQuantity: valueQuantity, valueCodeableConcept: nil, code: Code(coding: [coding])))
                }
            }
            
            let concept1 = ValueCodeableConcept(coding: [Coding(system: "urn:oid:2.16.840.1.113883.2.4.3.11.60.40.4.15.1", code: "STD", display: "Standaard")])
            let rcCode1 = Code(coding: [Coding(system: "http://loinc.org", code: "8358-4", display: "Blood pressure device Cuff size")])
            comp.append(ResourceComponent(valueQuantity: nil, valueCodeableConcept: concept1, code: rcCode1))
            
            let concept2 = ValueCodeableConcept(coding: [Coding(system: "http://snomed.info/sct", code: "33586001", display: "Zittende positie")])
            let rcCode2 = Code(coding: [Coding(system: "http://loinc.org", code: "8361-8", display: "Body position with respect to gravity")])
            comp.append(ResourceComponent(valueQuantity: nil, valueCodeableConcept: concept2, code: rcCode2))
            
            return comp
        default:
            return nil
        }
    }
    
    private var fhirObservationExtension: [ObservationExtension]? {
        switch type {
        case .bloodGlucose:
            let conceptCoding = Coding(system: "http://hl7.org/fhir/v3/TimingEvent", code: commentTiming ?? "", display: commentTiming ?? "")
            let concept = ValueCodeableConcept(coding: [conceptCoding])
            var details: [ExtensionDetail] = []
            let detail = ExtensionDetail(valueCodeableConcept: concept, valueQuantity: nil, url: "code")
            details.append(detail)
            
            if commentTiming == "PCV" || commentTiming == "PCM" {
                let vq = ValueQuantity(value: 120, unit: "min", code: "min", system: "http://unitsofmeasure.org")
                let additionalDetail = ExtensionDetail(valueCodeableConcept: nil, valueQuantity: vq, url: "offset")
                details.append(additionalDetail)
            }
            
            return [ObservationExtension(extension: details, url: "http://hl7.org/fhir/StructureDefinition/observation-eventTiming")]
        default:
            return nil
        }
    }
    
    private var valueQuantity: ValueQuantity? {
        guard let component = components.first else {
            return nil
        }
        
        switch type {
        case .bloodGlucose, .heartRate, .height, .weight:
            return ValueQuantity(value: component.measurementValue, unit: component.unit, code: component.unitCode, system: "http://unitsofmeasure.org")
        default:
            return nil
        }
    }
    
    private var bodySite: Code? {
        switch type {
        case .bloodPressure:
            return Code(
                coding: [Coding(system: "http://snomed.info/sct", code: "368208006", display: "Structuur van linker bovenarm")]
            )
        default:
            return nil
        }
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case type
        case createdDate
        case components
        case comment
        case commentName
        case commentCode
        case commentTiming
        case receipts
    }

    init(name: String, type: SelfMeasurementType, createdDate: Date, components: [SelfMeasurementComponent] = [], comment: String? = nil, commentName: String? = nil, commentCode: String? = nil, commentTiming: String? = nil, receipts: [SelfMeasurementReceipt] = []) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.createdDate = createdDate
        self.components = components
        self.comment = comment
        self.commentName = commentName
        self.commentCode = commentCode
        self.commentTiming = commentTiming
        self.receipts = receipts
    }

    init(id: UUID, name: String, type: SelfMeasurementType, createdDate: Date, components: [SelfMeasurementComponent] = [], comment: String? = nil, commentName: String? = nil, commentCode: String? = nil, commentTiming: String? = nil, receipts: [SelfMeasurementReceipt] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.createdDate = createdDate
        self.components = components
        self.comment = comment
        self.commentName = commentName
        self.commentCode = commentCode
        self.commentTiming = commentTiming
        self.receipts = receipts
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(SelfMeasurementType.self, forKey: .type)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.components = try container.decode([SelfMeasurementComponent].self, forKey: .components)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.commentName = try container.decodeIfPresent(String.self, forKey: .commentName)
        self.commentCode = try container.decodeIfPresent(String.self, forKey: .commentCode)
        self.commentTiming = try container.decodeIfPresent(String.self, forKey: .commentTiming)
        self.receipts = try container.decode([SelfMeasurementReceipt].self, forKey: .receipts)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.createdDate, forKey: .createdDate)
        try container.encode(self.components, forKey: .components)
        try container.encodeIfPresent(self.comment, forKey: .comment)
        try container.encodeIfPresent(self.commentName, forKey: .commentName)
        try container.encodeIfPresent(self.commentCode, forKey: .commentCode)
        try container.encodeIfPresent(self.commentTiming, forKey: .commentTiming)
        try container.encode(self.receipts, forKey: .receipts)
    }
}

extension SelfMeasurement: Identifiable {
    static func == (lhs: SelfMeasurement, rhs: SelfMeasurement) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SelfMeasurement: Comparable {
    static func < (lhs: SelfMeasurement, rhs: SelfMeasurement) -> Bool {
        return lhs == rhs
    }
}

struct FHIRBundle: Codable {
    let resourceType: String
    let type: String
    let entry: [ObservationEntry]
}

struct ObservationEntry: Codable {
    let resource: ObservationResource
    let request: ObservationRequest
    let fullUrl: String?
}

struct ObservationRequest: Codable {
    let method: String
    let url: String
}

struct ObservationResource: Codable {
    let identifier: [ObservationIdentifier]?
    let category: [ObservationCategory]?
    let resourceType: String?
    let status: String?
    let code: Code?
    let effectiveDateTime: String?
    let subject: ReferenceObject?
    let performer: [ReferenceObject]?
    let valueQuantity: ValueQuantity?
    let `extension`: [ObservationExtension]?
    let component: [ResourceComponent]?
    let method: Code?
    let interpretation: Code?
    let comment: String?
    let bodySite: Code?
    
    let _gender: GenderExtension?
    let name: [Name]?
    let birthDate: String?
    let text: ResourceText?
    let address: [PersonAddress]?
    let gender: String?
    let meta: ObservationMeta?
    let fullUrl: String?
}

struct ObservationIdentifier: Codable {
    let value: String
    let system: String
}

struct ObservationCategory: Codable {
    let coding: [Coding]
}

struct Coding: Codable {
    let system: String
    let code: String
    let display: String
}

struct Code: Codable {
    let coding: [Coding]
}

struct Subject: Codable {
    let reference: String
}

struct ValueQuantity: Codable {
    let value: Decimal
    let unit: String
    let code: String
    let system: String
}

struct ObservationExtension: Codable {
    let `extension`: [ExtensionDetail]
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case `extension`
        case url
    }
}

struct ExtensionDetail: Codable {
    let valueCodeableConcept: ValueCodeableConcept?
    let valueQuantity: ValueQuantity?
    let url: String
}

struct ValueCodeableConcept: Codable {
    let coding: [Coding]
}

struct ResourceComponent: Codable {
    let valueQuantity: ValueQuantity?
    let valueCodeableConcept: ValueCodeableConcept?
    let code: Code
}

struct GenderExtension: Codable {
    var `extension`: [GenderDetail]
}

struct GenderDetail: Codable {
    var valueCodeableConcept: ValueCodeableConcept
    var url: String
}

struct Name: Codable {
    var family: String
    var _given: [GivenExtension]
    var given: [String]
    var _family: FamilyExtension
}

struct GivenExtension: Codable {
    var `extension`: [GivenDetail]
}

struct GivenDetail: Codable {
    var valueCode: String
    var url: String
}

struct FamilyExtension: Codable {
    var `extension`: [FamilyDetail]
}

struct FamilyDetail: Codable {
    var valueString: String
    var url: String
}

struct ResourceText: Codable {
    var status: String
    var div: String
}

struct PersonAddress: Codable {
    var line: [String]
    var _line: [LineExtension]
    var postalCode: String
    var city: String
}

struct LineExtension: Codable {
    var `extension`: [LineDetail]
}

struct LineDetail: Codable {
    var valueString: String
    var url: String
}

struct ObservationMeta: Codable {
    var profile: [String]
}

struct ReferenceObject: Codable {
    let reference: String
    let display: String
}

extension SelfMeasurement {
    var typeDescription: String {
        switch type {
        case .heartRate:
            return "Heart Rate"
        case .weight:
            return "Weight"
        case .height:
            return "Height"
        case .bloodPressure:
            return "Blood Pressure"
        case .bloodGlucose:
            return "Blood Glucose"
        default:
            return "None"
        }
    }
}
