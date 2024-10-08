//
//  HealthDataService.swift
//  DigiMeSDKExample
//
//  Created on 13/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import DigiMeCore
import DigiMeHealthKit
import DigiMeSDK
import Foundation
import ModelsR5
import SwiftData
import HealthKit

@available(iOS 17.0, *)
class HealthDataService {
    private let quantityConverters: [QuantityType: FHIRObservationConverter] = [
        .height: HeightObservationConverter(),
        .bodyMass: BodyMassObservationConverter(),
        .bodyTemperature: TemperatureObservationConverter(),
        .oxygenSaturation: OxygenSaturationObservationConverter(),
        .respiratoryRate: RespiratoryRateObservationConverter(),
        .heartRate: HeartRateObservationConverter(),
        .bloodPressureSystolic: BloodPressureObservationConverter(),
        .bloodPressureDiastolic: BloodPressureObservationConverter(),
        .bloodGlucose: BloodGlucoseObservationConverter(),
    ]
    private let correlationConverters: [CorrelationType: FHIRObservationConverter] = [
        .bloodPressure: BloodPressureObservationConverter(),
    ]
    private var reporter: HealthKitService
    private var authorisationTypes: [QuantityType: AggregationType]
    private var modelContainer: ModelContainer
    private let queriesQueue = DispatchQueue(label: "me.digi.sdk.healthDataService.queriesQueue")
    private var queries: [HKQuery] = []

    init(modelContainer: ModelContainer, healthKitService: HealthKitService? = nil, authorisationTypes: [QuantityType: AggregationType] = [:]) {
        self.modelContainer = modelContainer
        self.reporter = healthKitService ?? HealthKitService()
        self.authorisationTypes = authorisationTypes
    }

    func loadHealthData(from startDate: Date, to endDate: Date, authorisationTypes: [QuantityType: AggregationType]) async throws {
        self.authorisationTypes = authorisationTypes
        let authorized = try await authorize()
        guard authorized else {
            throw SDKError.healthDataError(message: "Authorization failed")
        }

        try await executeQueries(from: startDate, to: endDate)
    }

    // MARK: - Private

    private func authorize() async throws -> Bool {
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
            let types = Array(self.authorisationTypes.keys)
            reporter.manager.requestAuthorization(toRead: types, toWrite: []) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    // MARK: - Queries

    private func executeQueries(from startDate: Date, to endDate: Date) async throws {
        for (type, aggregationType) in authorisationTypes {
            if aggregationType == .none {
                if type == .bloodPressureSystolic || type == .bloodPressureDiastolic {
                    try await queryCorrelationType(.bloodPressure, from: startDate, to: endDate)
                } else {
                    try await queryQuantityType(type, from: startDate, to: endDate)
                }
            } else {
                if type == .bloodPressureSystolic || type == .bloodPressureDiastolic {
                    try await queryAggregatedBloodPressure(from: startDate, to: endDate, aggregationType: aggregationType)
                } else {
                    try await queryAggregatedQuantityType(type, from: startDate, to: endDate, aggregationType: aggregationType)
                }
            }
        }
    }
    
    private func queryQuantityType(_ type: QuantityType, from startDate: Date, to endDate: Date) async throws {
        guard let converter = self.quantityConverters[type] else {
            throw SDKError.healthDataError(message: "Missing FHIR converter.")
        }

        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)

        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            do {
                let query = try self.reporter.reader.quantityQuery(type: type, unit: converter.unit, predicate: predicate) { results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let importer = BackgroundImporter(modelContainer: self.modelContainer)
                    importer.convertObjects(results, converter: converter, aggregationType: .none) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                }

                self.queriesQueue.async {
                    self.queries.append(query)
                }

                self.reporter.manager.executeQuery(query)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func queryCorrelationType(_ type: CorrelationType, from startDate: Date, to endDate: Date) async throws {
        guard let converter = self.correlationConverters[type] else {
            throw SDKError.healthDataError(message: "Missing FHIR converter.")
        }

        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)

        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            do {
                let query = try reporter.reader.correlationQuery(type: type, predicate: predicate) { results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let importer = BackgroundImporter(modelContainer: self.modelContainer)
                    importer.convertObjects(results, converter: converter, aggregationType: .none) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                }

                self.queriesQueue.async {
                    self.queries.append(query)
                }

                self.reporter.manager.executeQuery(query)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func queryAggregatedQuantityType(_ type: QuantityType, from startDate: Date, to endDate: Date, aggregationType: AggregationType) async throws {
        guard let converter = self.quantityConverters[type] else {
            throw SDKError.healthDataError(message: "Missing FHIR converter.")
        }

        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
        let intervalComponents = self.getIntervalComponents(for: aggregationType)

        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            do {
                let query = try self.reporter.reader.statisticsCollectionQuery(
                    type: type,
                    unit: converter.unit,
                    quantitySamplePredicate: predicate,
                    anchorDate: startDate,
                    enumerateFrom: startDate,
                    enumerateTo: endDate,
                    intervalComponents: intervalComponents
                ) { results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let results = results else {
                        continuation.resume(throwing: SDKError.healthDataError(message: "No results returned"))
                        return
                    }

                    let importer = BackgroundImporter(modelContainer: self.modelContainer)
                    importer.convertObjects(results, converter: converter, aggregationType: aggregationType) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                }

                // Keep a strong reference to the query
                self.queriesQueue.async {
                    self.queries.append(query)
                }

                self.reporter.manager.executeQuery(query)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func queryAggregatedBloodPressure(from startDate: Date, to endDate: Date, aggregationType: AggregationType) async throws {
        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
        let intervalComponents = self.getIntervalComponents(for: aggregationType)

        let systolicType = QuantityType.bloodPressureSystolic
        let diastolicType = QuantityType.bloodPressureDiastolic

        async let systolicResults: [DigiMeHealthKit.Statistics] = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<[DigiMeHealthKit.Statistics], Error>) in
            do {
                let systolicQuery = try self.reporter.reader.statisticsCollectionQuery(
                    type: systolicType,
                    unit: "mmHg",
                    quantitySamplePredicate: predicate,
                    anchorDate: startDate,
                    enumerateFrom: startDate,
                    enumerateTo: endDate,
                    intervalComponents: intervalComponents
                ) { results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: results ?? [])
                    }
                }

                self.queriesQueue.async {
                    self.queries.append(systolicQuery)
                }

                self.reporter.manager.executeQuery(systolicQuery)
            } catch {
                continuation.resume(throwing: error)
            }
        }

        async let diastolicResults: [DigiMeHealthKit.Statistics] = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<[DigiMeHealthKit.Statistics], Error>) in
            do {
                let diastolicQuery = try self.reporter.reader.statisticsCollectionQuery(
                    type: diastolicType,
                    unit: "mmHg",
                    quantitySamplePredicate: predicate,
                    anchorDate: startDate,
                    enumerateFrom: startDate,
                    enumerateTo: endDate,
                    intervalComponents: intervalComponents
                ) { results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: results ?? [])
                    }
                }

                self.queriesQueue.async {
                    self.queries.append(diastolicQuery)
                }

                self.reporter.manager.executeQuery(diastolicQuery)
            } catch {
                continuation.resume(throwing: error)
            }
        }

        let (systolic, diastolic) = try await (systolicResults, diastolicResults)
        let combinedResults = self.combineBloodPressureStats(systolic: systolic, diastolic: diastolic)

        let importer = BackgroundImporter(modelContainer: self.modelContainer)
        let converter = BloodPressureObservationConverter()

        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            importer.convertObjects(combinedResults, converter: converter, aggregationType: aggregationType) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private func combineBloodPressureStats(systolic: [DigiMeHealthKit.Statistics], diastolic: [DigiMeHealthKit.Statistics]) -> [CombinedBloodPressureStats] {
        var combined: [CombinedBloodPressureStats] = []

        for (systolicStat, diastolicStat) in zip(systolic, diastolic) {
            let combinedStat = CombinedBloodPressureStats(
                identifier: "CombinedBloodPressureStats",
                startDate: Date(timeIntervalSince1970: systolicStat.startTimestamp),
                endDate: Date(timeIntervalSince1970: systolicStat.endTimestamp),
                systolic: systolicStat,
                diastolic: diastolicStat
            )
            combined.append(combinedStat)
        }

        return combined
    }

    private func getIntervalComponents(for aggregationType: AggregationType) -> DateComponents {
        switch aggregationType {
        case .none:
            return DateComponents()
        case .daily:
            return DateComponents(day: 1)
        case .weekly:
            return DateComponents(weekOfYear: 1)
        case .monthly:
            return DateComponents(month: 1)
        case .yearly:
            return DateComponents(year: 1)
        }
    }
}
#endif
