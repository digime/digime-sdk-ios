//
//  HealthKitDataQuantityOperation.swift
//  DigiMeSDK
//
//  Created on 31/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import HealthKit
import Foundation

public struct HealthDataOperationResult: Codable {
    public var account: SourceAccount
    public var data: [String: [FitnessActivitySummary]]
}

class HealthKitDataQuantityOperation: RetryingOperation {
    var operationCompletion: ((Result<HealthDataOperationResult, SDKError>) -> Void)?
    
    private let startDate: Date
    private let endDate: Date
    private let dataType: ObjectType
    private let account: SourceAccount
	private let healthStore: HKHealthStore
	
	init(from startDate: Date, to endDate: Date, with dataType: ObjectType, healthStore: HKHealthStore, account: SourceAccount) {
        self.startDate = startDate
        self.endDate = endDate
        self.dataType = dataType
		self.healthStore = healthStore
        self.account = account
        
        super.init()
    }
    
    override func main() {
        guard
			!isCancelled,
			let quantityType = (dataType.original as? HKQuantityType) else {
            finish()
            return
        }
		
		let statisticsOptions = quantityType.statisticsOptions
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let dateInterval = DateComponents(day: 1)
        
        let initialResultsHandler: (Result<HKStatisticsCollection, SDKError>) -> Void = { [self] result in

            switch result {
            case .success(let statisticsCollection):
                
                var values: [FitnessActivitySummary] = []
                statisticsCollection.enumerateStatistics(from: self.startDate, to: self.endDate) { [self] statistics, obj in
                    					
                    var steps = 0.0
                    var distance = 0.0
					var activeEnergyBurned = 0.0
                    var appleExerciseTime = 0
                    
					if
						let unit = preferredUnit(for: quantityType),
						let statisticsQuantity = getStatisticsQuantity(for: statistics, with: statisticsOptions),
						let typeIdentifier = dataType.original?.identifier {
                        
						let value = statisticsQuantity.doubleValue(for: unit)
						switch HKQuantityTypeIdentifier(rawValue: typeIdentifier) {
						case .stepCount:
							steps = value
						case .distanceWalkingRunning:
							distance = (value / 1_000)
						case .activeEnergyBurned:
							activeEnergyBurned = value
                        case .appleExerciseTime:
                            appleExerciseTime = Int(value)
                        default:
                            break
                        }
                    }
                    
                    guard
                        statistics.endDate <= endDate,
                        !(steps == 0.0 && distance == 0.0 && activeEnergyBurned == 0.0 && appleExerciseTime == 0) else {
                        return
                    }

                    let distances = FitnessActivitySummary.Distances(activity: "total", distance: distance)
                    let activity = FitnessActivitySummary(startDate: statistics.startDate, endDate: statistics.endDate, steps: steps, distances: [distances], calories: activeEnergyBurned, activity: appleExerciseTime, account: self.account)
                    values.append(activity)
                }
                
                let sorted = values.sorted { $0.startDate > $1.startDate }
                let result = HealthDataOperationResult(account: account, data: [dataType.original!.identifier: sorted])
                operationCompletion?(.success(result))
                finish()
                
            case .failure(let error):
                operationCompletion?(.failure(error))
                finish()
            }
        }
        
		let query = HKStatisticsCollectionQuery(quantityType: quantityType,
												quantitySamplePredicate: predicate,
												options: statisticsOptions,
												anchorDate: createAnchorDate(from: startDate),
												intervalComponents: dateInterval)
		
		query.initialResultsHandler = { _, results, error in
			if let error = error {
				initialResultsHandler(.failure(.healthDataFetchStatistics(error: error)))
			}
			else if let statsCollection = results {
				initialResultsHandler(.success(statsCollection))
			}
			else {
				initialResultsHandler(.failure(.healthDataError(message: "HKStatisticsCollectionQuery error.")))
			}
		}
		 
		healthStore.execute(query)
    }
    
    override func cancel() {
        operationCompletion = nil
        super.cancel()
    }
    
    private func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
        var statisticsQuantity: HKQuantity?

        switch statisticsOptions {
        case .cumulativeSum:
            statisticsQuantity = statistics.sumQuantity()
        case .discreteAverage:
            statisticsQuantity = statistics.averageQuantity()
        case .duration:
            statisticsQuantity = statistics.duration()
        default:
            break
        }

        return statisticsQuantity
    }
		
	private func createAnchorDate(from date: Date) -> Date {
		// Set the arbitrary anchor date to Monday at 0:00 a.m.
		let calendar: Calendar = .current
		var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: date)
		let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7
		
		anchorComponents.day! -= offset
		anchorComponents.hour = 0
		
		let anchorDate = calendar.date(from: anchorComponents)!
		
		return anchorDate
	}

	private func preferredUnit(for sample: HKSample) -> HKUnit? {
        let unit = preferredUnit(for: sample.sampleType)

        if let quantitySample = sample as? HKQuantitySample, let unit = unit {
            assert(quantitySample.quantity.is(compatibleWith: unit), "The preferred unit is not compatiable with this sample.")
        }

        return unit
    }
	
	private func preferredUnit(for sampleType: HKSampleType) -> HKUnit? {
        var unit: HKUnit?

        if sampleType is HKQuantityType {
			let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: sampleType.identifier)

            switch quantityTypeIdentifier {
            case .stepCount:
                unit = .count()
            case .distanceWalkingRunning:
				unit = .meter()
			case .activeEnergyBurned:
				unit = .kilocalorie()
            case .appleExerciseTime:
                unit = .minute()
            default:
                break
            }
        }

        return unit
    }
}
