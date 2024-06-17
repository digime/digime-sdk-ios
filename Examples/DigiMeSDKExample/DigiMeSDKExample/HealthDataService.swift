//
//  HealthDataService.swift
//  DigiMeSDKExample
//
//  Created on 13/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import DigiMeSDK
import Foundation
import ModelsR5
import SwiftData

class HealthDataService {
    private let quantityConverters: [QuantityType: FHIRObservationConverter] = [
        .height: HeightObservationConverter(),
        .bodyMass: BodyMassObservationConverter(),
        .bodyTemperature: TemperatureObservationConverter(),
        .oxygenSaturation: OxygenSaturationObservationConverter(),
        .respiratoryRate: RespiratoryRateObservationConverter(),
        .heartRate: HeartRateObservationConverter(),
//        .bloodPressureSystolic: BloodSystolicObservationConverter(),
//        .bloodPressureDiastolic: BloodDiastolicObservationConverter(),
        .bloodGlucose: BloodGlucoseObservationConverter(),
    ]
    private let correlationConverters: [CorrelationType: FHIRObservationConverter] = [
        .bloodPressure: BloodPressureObservationConverter(),
    ]
    private var reporter: HealthKitService
    private var authorisationTypes: [SampleType] = [
        QuantityType.height,
        QuantityType.bodyMass,
        QuantityType.bodyTemperature,
        QuantityType.oxygenSaturation,
        QuantityType.respiratoryRate,
        QuantityType.heartRate,
        QuantityType.bloodPressureSystolic,
        QuantityType.bloodPressureDiastolic,
        QuantityType.bloodGlucose,
    ]
    private var quantityTypes: [QuantityType] = [
        QuantityType.height,
        QuantityType.bodyMass,
        QuantityType.bodyTemperature,
        QuantityType.oxygenSaturation,
        QuantityType.respiratoryRate,
        QuantityType.heartRate,
        QuantityType.bloodGlucose,
    ]
    private var correlationTypes: [CorrelationType] = [
        CorrelationType.bloodPressure,
    ]

    private var modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        reporter = HealthKitService()
    }

    init(modelContainer: ModelContainer, healthKitService: HealthKitService, authTypes: [SampleType] = [], quantityTypes: [QuantityType] = [], correlationTypes: [CorrelationType] = []) {
        self.modelContainer = modelContainer
        self.reporter = healthKitService
        self.authorisationTypes = authTypes
        self.quantityTypes = quantityTypes
        self.correlationTypes = correlationTypes
    }

    func authorize(completion: @escaping (Bool, Error?) -> Void) {
        reporter.manager.requestAuthorization(toRead: authorisationTypes, toWrite: authorisationTypes, completion: completion)
    }

    func loadHealthData(from startDate: Date, to endDate: Date, authorisationTypes: [QuantityType], completion: @escaping (Error?) -> Void) {
        self.authorisationTypes = authorisationTypes
        self.quantityTypes = authorisationTypes.filter { type in
            type != .bloodPressureSystolic && type != .bloodPressureDiastolic
        }
        self.correlationTypes = authorisationTypes.contains { $0 == .bloodPressureSystolic || $0 == .bloodPressureDiastolic } ? [.bloodPressure] : []

        authorize { authorized, error in
            guard authorized else {
                completion(error ?? SDKError.healthDataError(message: "Authorization failed"))
                return
            }
            self.executeQueries(from: startDate, to: endDate, completion: completion)
        }
    }

    // MARK: - Queries

    private func executeQueries(from startDate: Date, to endDate: Date, completion: @escaping (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        for type in quantityTypes {
            dispatchGroup.enter()
            queryQuantityType(type, from: startDate, to: endDate) { error in
                if let error = error {
                    completion(error)
                    return
                }
                dispatchGroup.leave()
            }
        }

        for type in correlationTypes {
            dispatchGroup.enter()
            queryCorrelationType(type, from: startDate, to: endDate) { error in
                if let error = error {
                    completion(error)
                    return
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }

    private func queryQuantityType(_ type: QuantityType, from startDate: Date, to endDate: Date, completion: @escaping (Error?) -> Void) {
        reporter.manager.preferredUnits(for: [type]) { preferredUnits, error in
            guard error == nil else {

                completion(error)
                return
            }

            for preferredUnit in preferredUnits {
                do {
                    if
                        let type = try? QuantityType.make(from: preferredUnit.identifier),
                        let converter = self.quantityConverters[type] {

                        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
                        let query = try self.reporter.reader.quantityQuery(type: type, unit: preferredUnit.unit, predicate: predicate) { results, error in
                            guard error == nil else {
                                completion(error)
                                return
                            }

//                            self.convertObjects(results, converter: converter, completion: completion)
                            let importer = BackgroundImporter(modelContainer: self.modelContainer)
                            importer.convertObjects(results, converter: converter, completion: completion)
                        }

                        self.reporter.manager.executeQuery(query)
                    }
                    else {
                        completion(SDKError.healthDataError(message: "Missing FHIR converter."))
                    }
                }
                catch {
                    completion(error)
                }
            }
        }
    }

    private func queryCorrelationType(_ type: CorrelationType, from startDate: Date, to endDate: Date, completion: @escaping (Error?) -> Void) {
        do {
            if let converter = self.correlationConverters[type] {

                let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
                let query = try reporter.reader.correlationQuery(type: type, predicate: predicate) { results, error in
                    guard error == nil else {
                        completion(error)
                        return
                    }

                    let importer = BackgroundImporter(modelContainer: self.modelContainer)
                    importer.convertObjects(results, converter: converter, completion: completion)
                }

                self.reporter.manager.executeQuery(query)
            }
            else {
                completion(SDKError.healthDataError(message: "Missing FHIR converter."))
            }
        }
        catch {
            completion(error)
        }
    }

    // MARK: - Utilities

//    private func convertObjects(_ data: [PayloadIdentifiable], converter: FHIRObservationConverter, completion: @escaping ((Error?) -> Void)) {
//        let type = converter.dataConverterType()
//        guard let typeIdentifier = type.identifier else {
//            completion(SDKError.healthDataError(message: "Error. Object converter failed for a type - \(type). Expected data converter type identifier."))
//            return
//        }
//
//        let modelContext = ModelContext(modelContainer)
//        modelContext.autosaveEnabled = false
//        let batchSize = 100
//        let section = HealthDataExportSection(typeIdentifier: type.identifier!)
//        var items: [HealthDataExportItem] = []
//        modelContext.insert(section)
//        try? modelContext.save()
//
//        for (index, element) in data.enumerated() {
//            if
//                let observation = converter.convertToObservation(data: element),
//                let jsonData = try? observation.encoded() {
//
//                let itemCreatedDate = converter.getCreatedDate(data: element)
//                let item = HealthDataExportItem(typeIdentifier: typeIdentifier, createdDate: itemCreatedDate, stringValue: converter.getFormattedValueString(data: element), parentId: section.id.uuidString, jsonData: jsonData)
//                items.append(item)
//                section.update(item.createdDate)
//
//                if items.count >= batchSize || index == data.count - 1 {
//                    let itemsToSave = items
//                    for item in itemsToSave {
//                        modelContext.insert(item)
//                    }
//                    try? modelContext.save()
//                }
//            }
//            else {
//                completion(SDKError.healthDataError(message: "Error. Observation ignored. FHIR data export failed for data type: \(type)"))
//            }
//        }
//
//        completion(nil)
//    }
}
