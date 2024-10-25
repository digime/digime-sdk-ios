//
//  HealthKitService.swift
//  DigiMeHealthKit
//
//  Created on 23/09/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

import DigiMeCore
import HealthKit

/// ***HKQueryAnchor** typealias
public typealias Anchor = HKQueryAnchor
/// **HKQuery** typealias
public typealias Query = HKQuery
/// **HKObserverQuery** typealias
public typealias ObserverQuery = HKObserverQuery
/// **HKSampleQuery** typealias
public typealias SampleQuery = HKSampleQuery
/// **HKStatisticsQuery** typealias
public typealias StatisticsQuery = HKStatisticsQuery
/// **HKStatisticsCollectionQuery** typealias
public typealias StatisticsCollectionQuery = HKStatisticsCollectionQuery
/// **HKActivitySummaryQuery** typealias
public typealias ActivitySummaryQuery = HKActivitySummaryQuery
/// **HKAnchoredObjectQuery** typealias
public typealias AnchoredObjectQuery = HKAnchoredObjectQuery
/// **HKSourceQuery** typealias
public typealias SourceQuery = HKSourceQuery
/// **HKCorrelationQuery** typealias
public typealias CorrelationQuery = HKCorrelationQuery

/**
 - Parameters:
    - success: the status
    - error: error (optional)
 */
public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void

/**
 - Parameters:
    - identifier: the object type identifier
    - error: error (optional)
 */
public typealias ObserverUpdateHandler = (_ query: Query?, _ identifier: String?, _ error: Error?) -> Void

/**
 - Parameters:
    - success: the status
    - id: the deleted object id
    - error: error (optional)
*/
public typealias DeletionCompletionBlock = (_ success: Bool, _ id: Int, _ error: Error?) -> Void

/**
 - Parameters:
    - samples: sample array. Empty by default
    - error: error (optional)
 */
public typealias SampleResultsHandler = (_ query: Query?, _ samples: [Sample], _ error: Error?) -> Void

/**
 - Parameters:
    - samples: sample array. Empty by default
    - deletedObjects: samples array that has been deleted
    - anchor: The anchor which was returned by a previous HKAnchoredObjectQuery result or update
    - error: error (optional)
 */
public typealias AnchoredResultsHandler = (_ query: Query?, _ samples: [Sample], _ deletedObjects: [DeletedObject], _ anchor: Anchor?, _ error: Error?) -> Void

/**
 - Parameters:
    - series: heartbeat series.
    - error: error (optional)
 */
public typealias HeartbeatSeriesResultsDataHandler = (_ series: [HeartbeatSeries], _ error: Error?) -> Void

/**
 - Parameters:
    - routes: workout routes.
    - error: error (optional)
 */
public typealias WorkoutRouteResultsDataHandler = (_ routes: [WorkoutRoute], _ error: Error?) -> Void

/**
 - Parameters:
    - summaries: summary array. Empty by default
    - error: error (optional)
 */
public typealias ActivitySummaryCompletionHandler = (_ summaries: [ActivitySummary], _ error: Error?) -> Void

/**
 - Parameters:
    - sources: source array. Empty by default
    - error: error (optional)
 */
public typealias SourceCompletionHandler = (_ sources: [Source], _ error: Error?) -> Void

/**
 - Parameters:
    - correlations: correlation array. Empty by default
    - error: error (optional)
 */
public typealias CorrelationCompletionHandler = (_ correlations: [Correlation], _ error: Error?) -> Void

/**
 - Parameters:
    - samples: quantity sample array. Empty by default
    - error: error (optional)
 */
public typealias QuantityResultsHandler = (_ samples: [Quantity], _ error: Error?) -> Void

/**
 - Parameters:
    - samples: correlation sample array. Empty by default
    - error: error (optional)
 */
public typealias CorrelationResultsHandler = (_ samples: [Correlation], _ error: Error?) -> Void

/**
 - Parameters:
    - statistics: statistics. Nil by default
    - error: error (optional)
 */
public typealias StatisticsCompletionHandler = (_ statistics: [Statistics]?, _ error: Error?) -> Void

/**
 - Parameters:
    - samples: category sample array. Empty by default
    - error: error (optional)
 */
public typealias CategoryResultsHandler = (_ samples: [Category], _ error: Error?) -> Void

/**
 - Parameters:
    - samples: workout sample array. Empty by default
    - error: error (optional)
 */
public typealias WorkoutResultsHandler = (_ samples: [Workout], _ error: Error?) -> Void

/**
 - Parameters:
    - preferredUnits: an array of **PreferredUnit**
    - error: error (optional)
*/
public typealias PreferredUnitsCompeltion = (_ preferredUnits: [PreferredUnit], _ error: Error?) -> Void

/**
 - Parameters:
    - ecgs: electrocardiogram sample array
    - error: error (optional)
 */
@available(iOS 14.0, *)
public typealias ElectrocardiogramResultsHandler = (_ ecgs: [Electrocardiogram], _ error: Error?) -> Void

/**
 - Parameters:
    - samples: electrocardiogram voltage measurements sample array. Empty by default
    - error: error (optional)
 */

/// **HealthKitService** class for HK easy integration
public class HealthKitService: HealthKitServiceProtocol {    
    /// **HealthKitReader** is reponsible for reading operations in HK
    public let reader: HealthKitReader
    /// **HealthKitWriter** is reponsible for writing operations in HK
    public let writer: HealthKitWriter
    /// **HealthKitObserver** is reponsible for observing in HK
    public let observer: HealthKitObserver
    /// **HealthKitManager** is reponsible for authorization and other operations
    public let manager: HealthKitManager
    /**
     Inits the instance of **HealthKitService** class.
     Every time when called, the new instance of **HKHealthStore** is created.
     - Requires: Apple Healt App is installed on the device.
     */
    public required init() {
        let healthStore = HKHealthStore()
        self.reader = HealthKitReader(healthStore: healthStore)
        self.writer = HealthKitWriter(healthStore: healthStore)
        self.observer = HealthKitObserver(healthStore: healthStore)
        self.manager = HealthKitManager(healthStore: healthStore)
    }
    
    public func requestAuthorization(typesToRead: [ReadableObjectType], typesToWrite: [WritableSampleType], completion: @escaping (Bool, Error?) -> Void) {
        Logger.mixpanel("device-data-source-auth-started", metadata: HealthKitAccountDataProvider().metadata)
        
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = SDKError.healthDataIsNotAvailable
            Logger.mixpanel("device-data-source-auth-failed", metadata: HealthKitAccountDataProvider().metadata)
            reportErrorLog(error: error)
            completion(false, error)
            return
        }
        
        let toRead: [ObjectType] = typesToRead.compactMap { $0 as? ObjectType }
        let toWrite: [SampleType] = typesToWrite.compactMap { $0 as? SampleType }

        manager.requestAuthorization(toRead: toRead, toWrite: toWrite) { success, error in
            if let error = error {
                Logger.mixpanel("device-data-source-auth-failed", metadata: HealthKitAccountDataProvider().metadata)
                self.reportErrorLog(error: error)
                completion(success, error)
            }
            
            if success {
                Logger.mixpanel("device-data-source-auth-success", metadata: HealthKitAccountDataProvider().metadata)
                Logger.info("HealthKit authorization request was successful.")
                completion(success, nil)
            }
            else {
                Logger.mixpanel("device-data-source-auth-unsuccessful", metadata: HealthKitAccountDataProvider().metadata)
                let error = SDKError.healthDataError(message: "HealthKit authorization was NOT successful.")
                self.reportErrorLog(error: error)
                completion(success, error)
            }
        }
    }
    
    public func reportErrorLog(error: Error?) {
        guard let error = error else {
            return
        }
        
        var meta = HealthKitAccountDataProvider().metadata
        if let sdk = error as? SDKError {
            meta.message = sdk.description
        }
        else {
            meta.message = error.localizedDescription
        }
        meta.code = "\((error as NSError).code)"
        Logger.mixpanel("device-data-source-read-failed", metadata: meta)
    }
    
    
#if targetEnvironment(simulator)
    /// iOS Simulator doesn't have any health data by default.
    /// Here we create some random data for testing purposes.
    public func addTestData(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        var dataToWrite: [HKQuantitySample] = []
        let startDate = Date.from(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
        let endDate = Date().endOfTomorrow
        let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
        var counter: Int = 0
        for date in stride(from: startDate, to: endDate, by: dayDurationInSeconds) {
            let end = Calendar.utcCalendar.date(byAdding: .minute, value: -1, to: date)!.endOfDay
            let start = Calendar.utcCalendar.startOfDay(for: end)
            print("Start: \(start) End: \(end)")

            // steps data
            let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
            let stepsQuantity = HKQuantity(unit: .count(), doubleValue: Double.random(in: 1...10))
            let steps = HKQuantitySample(type: stepsType, quantity: stepsQuantity, start: start, end: end)
            dataToWrite.append(steps)
            
            // distance walking & running
            let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let distanceQuantity = HKQuantity(unit: .mile(), doubleValue: Double.random(in: 1...10))
            let walk = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: start, end: end)
            dataToWrite.append(walk)
            
            // active energy burned
            let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
            let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: Double.random(in: 1...10))
            let energy = HKQuantitySample(type: energyType, quantity: energyQuantity, start: start, end: end)
            dataToWrite.append(energy)

            counter += 1
        }
        
        writer.saveData(dataToWrite, completion: completion)
    }
#endif
}
