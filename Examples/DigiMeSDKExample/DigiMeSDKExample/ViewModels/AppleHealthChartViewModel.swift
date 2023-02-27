//
//  AppleHealthChartViewModel.swift
//  DigiMeSDKExample
//
//  Created on 02/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

class AppleHealthChartViewModel: ObservableObject {
	@Published var result: [FitnessActivitySummary] = []
	@Published var result30days: [FitnessActivitySummary] = []
	@Published var data30InSeries: [ChartSeries] = []
	@Published var dataMonthsInSeries: [ChartSeries] = []

	@Published var isLoading = false
	@Published var dataFetched = false
	@Published var errorMessage: String?
	@Published var minStartDate: Date?
	@Published var maxEndDate: Date?
	
	private let preferences = UserPreferences.shared()
	private let endDate = Date()
	private let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
	
	private var digiMe: DigiMe?
	private var config: Configuration
	private var readOptions: ReadOptions?
	private var formatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}

	private var last30Days: [FitnessActivitySummary] {
		result.filter { $0.startDate >= startDate && $0.endDate <= endDate }
	}

	init(config: Configuration) {
		self.config = config
		self.digiMe = DigiMe(configuration: config)
	}
	
	func fetchData(readOptions: ReadOptions? = nil) {
		self.readOptions = readOptions
		dataFetched = false
		isLoading = true
		let credentials = preferences.credentials(for: config.contractId)
		var files: [File] = []
		digiMe?.authorize(credentials: credentials, serviceId: DeviceOnlyServices.appleHealth.rawValue) { result in
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.config.contractId)
				self.digiMe?.readAllFiles(credentials: newOrRefreshedCredentials, readOptions: readOptions) { result in
					switch result {
					case .success(let file):
						files.append(file)
						print("[DigiMeSDKExample] JFS file received \(file.identifier)")
					case .failure(let error):
						self.handleError(error)
					}
				} completion: { result in
					switch result {
					case .success(let (fileList, refreshedCredentials)):
						self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.config.contractId)
						
						if
							let accountState = fileList.status.details?.first,
							let date = accountState.error?.error?.retryAfter {
							
							print("[DigiMeSDKExample] Next sync date: \(date), sync state: \(fileList.status.state)")
						}
						
						self.process(jfs: files)
						self.isLoading = false
						
					case .failure(let error):
						self.handleError(error)
					}
				}
				
			case.failure(let error):
				self.handleError(error)
			}
		}
	}
	
	// MARK: - Private
	
	private func process(jfs files: [File]) {
		let refDate = Date()
		var binder: [FitnessActivitySummary] = []
		var responseStartDate = refDate
		var responseEndDate = Date(timeIntervalSince1970: 0)

		files.forEach { file in
			FilePersistentStorage(with: .documentDirectory).store(data: file.data, fileName: file.identifier)
			let activities = try? file.data.decoded(dateDecodingStrategy: .millisecondsSince1970) as [FitnessActivitySummary]
			activities?.forEach { activity in
				var distanceCounter = 0.0
				activity.distances.forEach { activityDistance in
					distanceCounter += activityDistance.distance
				}

				responseStartDate = responseStartDate < activity.startDate ? responseStartDate : activity.startDate
				responseEndDate = responseEndDate > activity.endDate ? responseEndDate : activity.endDate
				
				if
					activity.steps.isZero,
					distanceCounter.isZero,
					activity.calories.isZero,
					activity.activity == 0 {
					return
				}
				
				let distance = FitnessActivitySummary.Distances(activity: "", distance: distanceCounter)
				let activity = FitnessActivitySummary(startDate: activity.startDate, endDate: activity.endDate, steps: activity.steps, distances: [distance], calories: activity.calories, activity: activity.activity)
				binder.append(activity)
			}
		}
		
		minStartDate = responseStartDate != refDate ? responseStartDate : nil
		maxEndDate = responseEndDate != Date(timeIntervalSince1970: 0) ? responseEndDate : nil
		result = binder
		
		result30days = last30Days
		let steps30 = last30Days.map { ($0.startDate, $0.steps) }
		let calories30 = last30Days.map { ($0.startDate, $0.calories) }
		let grouped = groupByMonth(activities: result)
		let stepsMonths = reduceByMonth(data: grouped, by: "steps")
		let caloriesMonths = reduceByMonth(data: grouped, by: "calories")
		data30InSeries = [
			ChartSeries(name: "Steps", data: steps30),
			ChartSeries(name: "Calories", data: calories30),
		]
		
		dataMonthsInSeries = [
			ChartSeries(name: "Steps", data: stepsMonths),
			ChartSeries(name: "Calories", data: caloriesMonths),
		]
		dataFetched = true
	}
	
	private func groupByMonth(activities: [FitnessActivitySummary]) -> [(date: Date, records: [FitnessActivitySummary])] {
		return activities
			.sorted { $0.endDate > $1.endDate }
			.groupedBy(dateComponents: [.year, .month], shiftDateToMiddle: true)
			.map { ($0, $1) }
			.sorted { $0.0 > $1.0 }
	}
	
	private func reduceByMonth(data: [(date: Date, records: [FitnessActivitySummary])], by property: String) -> [(date: Date, value: Double)] {
		let getValue: (FitnessActivitySummary) -> Double = {
			switch property {
			case "steps":
				return $0.steps
			case "calories":
				return $0.calories
			default:
				return 0
			}
		}
		
		return data.map { date, records in
			(date, records.reduce(0) { $0 + getValue($1) })
		}
	}
	
	private func createAnchorDate(from: Date) -> Date {
		// Set the arbitrary anchor date to Monday at 0:00 a.m.
		let calendar: Calendar = .current
		var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: from)
		let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7
		anchorComponents.day! -= offset
		anchorComponents.hour = 0
		let anchorDate = calendar.date(from: anchorComponents)!
		return anchorDate
	}
		
	private func handleError(_ error: SDKError) {
		switch error {
		case .invalidSession:
			refreshCtredentials { success in
				if success {
					self.fetchData(readOptions: self.readOptions)
				}
			}
		default:
			isLoading = false
			errorMessage = error.description
		}
	}
	
	private func refreshCtredentials(_ completion: @escaping((Bool) -> Void)) {
		guard let credentials = preferences.credentials(for: config.contractId) else {
			errorMessage = "[DigiMeSDKExample] Attempting to read data before authorizing contract"
			return
		}
		
		digiMe?.requestDataQuery(credentials: credentials, readOptions: readOptions) { result in
			switch result {
			case .success(let credentials):
				self.preferences.setCredentials(newCredentials: credentials, for: self.config.contractId)
				completion(true)
				
			case .failure(let error):
				self.errorMessage = "[DigiMeSDKExample] Refresh Credentials failed: \(error)"
				completion(false)
			}
		}
	}
}
