//
//  HealthKitService.swift
//  DigiMeSDK
//
//  Created on 23.09.20.
//

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
public class HealthKitService {	
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
     - Returns: **HealthKitService** instance
     */
    public init() {
        let healthStore = HKHealthStore()
        self.reader = HealthKitReader(healthStore: healthStore)
        self.writer = HealthKitWriter(healthStore: healthStore)
        self.observer = HealthKitObserver(healthStore: healthStore)
        self.manager = HealthKitManager(healthStore: healthStore)
    }
	
	func requestAuthorization(typesToRead: [ObjectType], typesToWrite: [SampleType], completion: @escaping StatusCompletionBlock) {
		Logger.mixpanel("device-data-source-auth-started", metadata: HealthKitData().metadata)
		
		guard HKHealthStore.isHealthDataAvailable() else {
			let error = SDKError.healthDataIsNotAvailable
			Logger.mixpanel("device-data-source-auth-failed", metadata: HealthKitData().metadata)
			HealthKitService.reportErrorLog(error: error)
			completion(false, error)
			return
		}
		
		manager.requestAuthorization(toRead: typesToRead, toWrite: typesToWrite) { success, error in
			if let error = error {
				Logger.mixpanel("device-data-source-auth-failed", metadata: HealthKitData().metadata)
				HealthKitService.reportErrorLog(error: error)
				completion(success, error)
			}
			
			if success {
				Logger.mixpanel("device-data-source-auth-success", metadata: HealthKitData().metadata)
				Logger.info("HealthKit authorization request was successful.")
				completion(success, nil)
			}
			else {
				Logger.mixpanel("device-data-source-auth-unsuccessful", metadata: HealthKitData().metadata)
				let error = SDKError.healthDataError(message: "HealthKit authorization was NOT successful.")
				HealthKitService.reportErrorLog(error: error)
				completion(success, error)
			}
		}
	}
	
	func readStatisticsCollectionQuery(from: Date,
									   to: Date,
									   anchorDate: Date,
									   intervalComponents: DateComponents,
									   for objectTypes: [ObjectType],
									   mergeResultForSameType: Bool = false,
									   singleCallbackForAllTypes: Bool = true,
									   completionHandler: @escaping StatisticsCompletionHandler) {
		
		let quantityTypes = objectTypes.filter({ $0 is QuantityType}) as? [QuantityType] ?? []

		manager.requestAuthorization(toRead: quantityTypes, toWrite: []) { success, error in
			if let error = error {
				HealthKitService.reportErrorLog(error: error)
				completionHandler(nil, error)
			}
			else {
				self.manager.preferredUnits(for: quantityTypes) { preferredUnits, error in
					if error == nil {
						var result: [[Statistics]] = []

						for preferredUnit in preferredUnits {
							do {
								let singleCallbackHandler: StatisticsCompletionHandler = { data, error in

									guard error == nil else {
										HealthKitService.reportErrorLog(error: error)
										completionHandler(nil, error)
										return
									}
									
									result.append(data ?? [])

									if result.count == preferredUnits.count {
										completionHandler(result.flatMap { $0 }, nil)
									}
								}
								
								let type = try QuantityType.make(from: preferredUnit.identifier)
								let statisticsQuery = try self.reader.statisticsCollectionQuery(type: type,
																								unit: preferredUnit.unit,
																								anchorDate: anchorDate,
																								enumerateFrom: from,
																								enumerateTo: to,
																								intervalComponents: intervalComponents,
																								mergeResultForSameType: mergeResultForSameType,
																								enumerationBlock: singleCallbackForAllTypes ? singleCallbackHandler : completionHandler)
								self.manager.executeQuery(statisticsQuery)
							}
							catch {
								HealthKitService.reportErrorLog(error: error)
								completionHandler(nil, error)
							}
						}
					}
					else {
						HealthKitService.reportErrorLog(error: error)
						completionHandler(nil, error)
					}
				}
			}
		}
	}
		
	func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
		writer.saveData(data, completion: completion)
	}
	
	static func reportErrorLog(error: Error?) {
		guard let error = error else {
			return
		}
		
		var meta = HealthKitData().metadata
		if let sdk = error as? SDKError {
			meta.message = sdk.description
		}
		else {
			meta.message = error.localizedDescription
		}
		meta.code = "\((error as NSError).code)"
		Logger.mixpanel("device-data-source-read-failed", metadata: meta)
	}
}
