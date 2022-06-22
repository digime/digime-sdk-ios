//
//  HealthStore.swift
//  DigiMeSDK
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import HealthKit

enum HealthStore {
    
    static let healthStore = HKHealthStore()
    
    // MARK: - Authorization
    
    /// Request health data from HealthKit if needed, using the data types within `HealthStore.allHealthDataTypes`
    static func requestHealthDataAccessIfNeeded(completion: @escaping (Result<Any, SDKError>) -> Void) {
        let readDataTypes = Set(HealthDataTypes.readDataTypes)
        
#if targetEnvironment(simulator)
        let shareDataTypes = readDataTypes
#else
        let shareDataTypes = Set<HKSampleType>()
#endif
        
        requestHealthDataAccessIfNeeded(toShare: shareDataTypes, read: readDataTypes, completion: completion)
    }
    
    /// Request health data from HealthKit if needed.
    static func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?, read readTypes: Set<HKObjectType>?, completion: @escaping (Result<Any, SDKError>) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            completion(.failure(.healthDataIsNotAvailable))
        }
//        else if !healthStore.supportsHealthRecords() {
//            completion(.failure(.healthDataNotSupportsHealthRecords))
//        }
        else {
            Logger.info("Requesting HealthKit authorization.")
            healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
                if let error = error {
                    completion(.failure(.healthDataErrorError(error: error)))
                }
                
                if success {
                    shareTypes?.forEach { type in
                        if healthStore.authorizationStatus(for: type) != .sharingAuthorized {
                            completion(.failure(.healthDataError(message: "Permission Denied to \(type.identifier)")))
                        }
                    }
                    
                    Logger.info("HealthKit authorization request was successful.")
                    completion(.success(success))
                }
                else {
                    completion(.failure(.healthDataError(message: "HealthKit authorization was NOT successful.")))
                }
            }
        }
    }
    
    // MARK: - HKHealthStore
    
    static func saveData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.save(data, withCompletion: completion)
    }
    
    // MARK: - HKStatisticsCollectionQuery
    
    static func fetchStatistics(with identifier: HKQuantityTypeIdentifier, options: HKStatisticsOptions, interval: DateComponents, startDate: Date, endDate: Date = Date(), predicate: NSPredicate? = nil, completion: @escaping (Result<HKStatisticsCollection, SDKError>) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(.failure(.healthDataUnableToCreateQuantityType))
            return
        }
        
        let anchorDate = createAnchorDate()
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: predicate,
                                                options: options,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = { _, results, error in
            if let error = error {
                completion(.failure(.healthDataFetchStatistics(error: error)))
            }
            else if let statsCollection = results {
                completion(.success(statsCollection))
            }
            else {
                completion(.failure(.healthDataError(message: "HKStatisticsCollectionQuery error.")))
            }
        }
         
        healthStore.execute(query)
    }
    
    // MARK: - Helper Functions

    private static func createAnchorDate() -> Date {
        // Set the arbitrary anchor date to Monday at 0:00 a.m.
        let calendar: Calendar = .current
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
        let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7
    
        anchorComponents.day! -= offset
        anchorComponents.hour = 0
    
        let anchorDate = calendar.date(from: anchorComponents)!
    
        return anchorDate
    }
}
