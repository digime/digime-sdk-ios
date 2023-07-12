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

@MainActor
class AppleHealthSummaryViewModel: ObservableObject {
	@Published var isDataLoading = false
	@Published var isDataFetched = false
	@Published var steps: String = "0"
	@Published var distance: String = "0"
	@Published var calories: String = "0"
	@Published var startDateFormattedString = ScopeAddView.datePlaceholder
	@Published var endDateFormattedString = ScopeAddView.datePlaceholder
	@Published var errorMessage: String?
	@Published var infoMessage: String?
	@Published var showCancelOption = false {
		willSet {
			objectWillChange.send()
		}
	}
	
    private let activeContractId = Contracts.prodAppleHealth.identifier
	private let preferences = UserPreferences.shared()
	private var digiMeService: DigiMe?
	private var readOptions: ReadOptions?
	private var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}

	init(config: Configuration) {
		digiMeService = DigiMe(configuration: config)
	}
	
	func authorize(readOptions: ReadOptions? = nil) {
		self.readOptions = readOptions
		isDataFetched = false
		isDataLoading = true
		
		guard let credentials = preferences.getCredentials(for: activeContractId) else {
			showCancelOption = true
			digiMeService?.authorize(serviceId: DeviceOnlyServices.appleHealth.rawValue) { result in
				self.showCancelOption = false
				switch result {
				case .success(let newOrRefreshedCredentials):
					self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.activeContractId)
					self.fetchData(with: newOrRefreshedCredentials)
					
				case.failure(let error):
					self.handleError(error)
				}
			}
			return
		}
		
		self.fetchData(with: credentials)
	}
	
	func cancel() {
		isDataLoading = false
		showCancelOption = false
	}
	
	// MARK: - Private
	
	private func fetchData(with credentials: Credentials) {
		var files: [File] = []
		self.digiMeService?.readAllFiles(credentials: credentials, readOptions: readOptions) { result in
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
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContractId)
				
				if
					let accountState = fileList.status.details?.first,
					let date = accountState.error?.error?.retryAfter {
					
					print("[DigiMeSDKExample] Next sync date: \(date), sync state: \(fileList.status.state)")
				}
				
				self.process(jfs: files)
				self.isDataLoading = false
				
			case .failure(let error):
				self.handleError(error)
			}
		}
	}
	
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
			startDateFormattedString = ScopeAddView.datePlaceholder
			endDateFormattedString = ScopeAddView.datePlaceholder
		}
		else {
			startDateFormattedString = self.dateFormatter.string(from: responseStartDate)
			endDateFormattedString = self.dateFormatter.string(from: responseEndDate)
		}
		isDataFetched = true
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
					self.authorize(readOptions: self.readOptions)
				}
			}
		default:
			isDataLoading = false
			errorMessage = error.description
		}
	}
	
	private func refreshCtredentials(_ completion: @escaping((Bool) -> Void)) {
		guard let credentials = preferences.getCredentials(for: activeContractId) else {
			errorMessage = "[DigiMeSDKExample] Attempting to read data before authorizing contract"
			return
		}
		
		digiMeService?.requestDataQuery(credentials: credentials, readOptions: readOptions) { result in
			switch result {
			case .success(let credentials):
				self.preferences.setCredentials(newCredentials: credentials, for: self.activeContractId)
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
		isDataLoading = true
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
			
			digiMeService?.saveHealthData(dataToSave: dataToWrite) { result in
				DispatchQueue.main.async { [weak self] in
					self?.isDataLoading = false
					switch result {
					case .success(let success):
						self?.infoMessage = "Data is \(success ? "saved" : "NOT saved"), \(counter) samples added."
					case .failure(let error):
						self?.errorMessage = "An error occured saving test data: \(error)"
					}

					self?.authorize()
				}
			}
		}
	}
}
#endif
