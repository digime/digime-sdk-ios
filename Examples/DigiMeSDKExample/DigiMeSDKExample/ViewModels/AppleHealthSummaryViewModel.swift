//
//  AppleHealthSummaryViewModel.swift
//  DigiMeSDKExample
//
//  Created on 28/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import HealthKit

class AppleHealthSummaryViewModel: ObservableObject {
	@Published var isLoading = false
	@Published var dataFetched = false
	@Published var steps: String = "0"
	@Published var distance: String = "0"
	@Published var calories: String = "0"
	@Published var startDateString = ScopeView.datePlaceholder
	@Published var endDateString = ScopeView.datePlaceholder
	@Published var errorMessage: String?
	@Published var infoMessage: String?
	
	private let contract = Contracts.appleHealth
	private let preferences = UserPreferences.shared()
	private var digiMe: DigiMe?
	private var readOptions: ReadOptions?
	private var formatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}

	init(config: Configuration) {
		digiMe = DigiMe(configuration: config)
	}
	
	func fetchData(readOptions: ReadOptions? = nil) {
		self.readOptions = readOptions
		dataFetched = false
		isLoading = true
		let credentials = preferences.credentials(for: contract.identifier)
		var files: [File] = []
		digiMe?.authorize(credentials: credentials, serviceId: DeviceOnlyServices.appleHealth.rawValue) { result in
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.contract.identifier)
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
						self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.contract.identifier)
						
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
		var stepsCounter = 0.0
		var distanceCounter = 0.0
		var activeEnergyBurned = 0.0
		var responseStartDate = Date()
		var responseEndDate = Date(timeIntervalSince1970: 0)

		files.forEach { file in
			FilePersistentStorage(with: .documentDirectory).store(data: file.data, fileName: file.identifier)
			let activities = try? file.data.decoded(dateDecodingStrategy: .millisecondsSince1970) as [FitnessActivitySummary]
			activities?.forEach { activity in
				stepsCounter += activity.steps
				activeEnergyBurned += activity.calories
				activity.distances.forEach { activityDistance in
					distanceCounter += activityDistance.distance
				}

				responseStartDate = responseStartDate < activity.startDate ? responseStartDate : activity.startDate
				responseEndDate = responseEndDate > activity.endDate ? responseEndDate : activity.endDate
				print("[DigiMeSDKExample] Start: \(responseStartDate) End: \(responseEndDate)")
			}
		}

		steps = String(format: "%.f", stepsCounter)
		distance = DistanceFormatter.stringFormatForDistance(km: distanceCounter)
		calories = CaloriesFormatter.stringForCaloriesValue(activeEnergyBurned)
		if stepsCounter.isZero, distanceCounter.isZero, activeEnergyBurned.isZero {
			startDateString = ScopeView.datePlaceholder
			endDateString = ScopeView.datePlaceholder
		}
		else {
			startDateString = self.formatter.string(from: responseStartDate)
			endDateString = self.formatter.string(from: responseEndDate)
		}
		dataFetched = true
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
		guard let credentials = preferences.credentials(for: contract.identifier) else {
			errorMessage = "[DigiMeSDKExample] Attempting to read data before authorizing contract"
			return
		}
		
		digiMe?.requestDataQuery(credentials: credentials, readOptions: readOptions) { result in
			switch result {
			case .success(let credentials):
				self.preferences.setCredentials(newCredentials: credentials, for: self.contract.identifier)
				completion(true)
				
			case .failure(let error):
				self.errorMessage = "[DigiMeSDKExample] Refresh Credentials failed: \(error)"
				completion(false)
			}
		}
	}
}

#if targetEnvironment(simulator)
extension AppleHealthSummaryViewModel {
	/// iOS Simulator doesn't have any health data by default.
	/// Here we create some random data.
	func addTestData() {
		isLoading = true
		DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [self] in
			var dataToWrite: [HKQuantitySample] = []
			let startDate = Date.from(year: 2014, month: 6, day: 1, hour: 0, minute: 0, second: 0)!
			let endDate = Date().endOfTomorrow
			let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
			var counter: Int = 0
			for date in stride(from: startDate, to: endDate, by: dayDurationInSeconds) {
				let end = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: date)!.endOfDay
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
			
			digiMe?.saveHealthData(dataToSave: dataToWrite) { result in
				DispatchQueue.main.async { [weak self] in
					self?.isLoading = false
					switch result {
					case .success(let success):
						self?.infoMessage = "Data is \(success ? "saved" : "NOT saved"), \(counter) samples added."
					case .failure(let error):
						self?.errorMessage = "An error occured saving test data: \(error)"
					}

					self?.fetchData()
				}
			}
		}
	}
}
#endif
