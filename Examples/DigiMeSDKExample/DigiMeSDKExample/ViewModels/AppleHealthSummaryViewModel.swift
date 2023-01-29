//
//  AppleHealthSummaryViewModel.swift
//  DigiMeSDKExample
//
//  Created on 28/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

class AppleHealthSummaryViewModel: ObservableObject {
	@Published var isLoading = false
	@Published var dataFetched = false
	@Published var steps: String = "0"
	@Published var distance: String = "0"
	@Published var calories: String = "0"
	@Published var startDateString = AppleHealthSummaryView.datePlaceholder
	@Published var endDateString = AppleHealthSummaryView.datePlaceholder
	@Published var errorMessage: String?
	
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

	init() {
		guard let config = try? Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true) else {
			return
		}
		
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
	
	private func process(jfs files: [File]) {
		var stepsCounter = 0.0
		var distanceCounter = 0.0
		var activeEnergyBurned = 0.0
		var responseStartDate = Date()
		var responseEndDate = Date(timeIntervalSince1970: 0)

		files.forEach { file in
			FilePersistentStorage(with: .adminApplicationDirectory).store(data: file.data, fileName: file.identifier)
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
		startDateString = self.formatter.string(from: responseStartDate)
		endDateString = self.formatter.string(from: responseEndDate)
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
