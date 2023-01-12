//
//  AppleHealthSummaryViewController.swift
//  DigiMeSDKExample
//
//  Created on 04/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import HealthKit
import SVProgressHUD
import SwiftUI
import UIKit

class AppleHealthSummaryViewController: UIViewController {
	@IBOutlet private var startDateLabel: UILabel!
	@IBOutlet private var endDateLabel: UILabel!
	@IBOutlet private var stepsLabel: UILabel!
	@IBOutlet private var distanceLabel: UILabel!
	@IBOutlet private var caloriesLabel: UILabel!
	
	private let contract = Contracts.appleHealth
	private let fromDate = Date.from(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
	
	private var preferences = UserPreferences.shared()
	private var digiMe: DigiMe!
	private var formatter: DateFormatter = {
		let fm = DateFormatter()
		fm.locale = .current
		fm.dateStyle = .medium
		fm.timeStyle = . medium
		return fm
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		SVProgressHUD.setContainerView(self.view)
		configureClient()
	}
	
	private func configureClient() {
		do {
			/// On initialization create a configuration object with digi.me contract details.
			let config = try Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true)
			digiMe = DigiMe(configuration: config)
			
			/// Fetch fitness data. Use read options to narrow down the fetch request.
			/// Options have to include the date range shorter than your digi.me contract.
			/// Options are optional parameters. If not present it will return data for the whole date range of the contract.
			fetchData()
		}
		catch {
			SVProgressHUD.dismiss()
			self.showPopUp(message: "Unable to configure digi.me SDK: \(error.localizedDescription)")
		}
	}
	
	private func fetchData() {
		SVProgressHUD.show(withStatus: "Fetching data...")
		let credentials = preferences.credentials(for: contract.identifier)
		
		digiMe.authorize(credentials: credentials, serviceId: DeviceOnlyServices.appleHealth.rawValue) { result in
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.contract.identifier)
				
				/// This the main difference with the previous example.
				/// Here we will receive a single callback for the whole time range.
				/// In the previous example we were receiving in daily chunks.
				let mergeResultForSameType = true
				
				let types: [QuantityType] = [.stepCount, .activeEnergyBurned, .distanceWalkingRunning]
				let anchorDate = self.createAnchorDate(from: self.fromDate)
				let intervalComponents = DateComponents(day: 1)
				let healthConfiguration = HealthKitConfiguration(typesToRead: types, typesToWrite: [], startDate: self.fromDate, endDate: Date(), anchorDate: anchorDate, mergeResultForSameType: mergeResultForSameType, singleCallbackForAllTypes: true, intervalComponents: intervalComponents)
				
				self.digiMe.appleHealthStatisticsCollectionQuery(for: self.contract.identifier, queryConfig: healthConfiguration) { _ in
				} completion: { stats, error in
					SVProgressHUD.dismiss()
					
					if let error = error as? SDKError {
						self.showPopUp(message: error.description)
						return
					}
					
					DispatchQueue.main.async {
						stats?.forEach { stat in
							self.startDateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: stat.startTimestamp))
							self.endDateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: stat.endTimestamp))

							if stat.identifier == HKQuantityTypeIdentifier.stepCount.rawValue {
								self.stepsLabel.text = String(format: "%.f", stat.harmonized.summary ?? 0.0)
							}

							if stat.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
								self.distanceLabel.text = DistanceFormatter.stringFormatForDistance(km: stat.harmonized.summary ?? 0.0)
							}

							if stat.identifier == HKQuantityTypeIdentifier.activeEnergyBurned.rawValue {
								self.caloriesLabel.text = CaloriesFormatter.stringForCaloriesValue(stat.harmonized.summary ?? 0.0)
							}
						}
					}
				}
				
			case.failure(let error):
				self.showPopUp(message: "Authorization failed: \(error)")
			}
		}
	}
	
	@objc func dismissDetailsView() {
		navigationController?.dismiss(animated: true, completion: nil)
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
	
	private func showPopUp(message: String) {
		DispatchQueue.main.async {
			let alert = UIAlertController(title: "digi.me SDK", message: message, preferredStyle: .alert)
			alert.addAction(.init(title: "OK", style: .cancel))
			self.present(alert, animated: true)
		}
	}
}
