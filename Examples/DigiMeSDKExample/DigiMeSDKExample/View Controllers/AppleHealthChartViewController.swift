//
//  AppleHealthChartViewController.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import HealthKit
import SVProgressHUD
import SwiftUI
import UIKit

class AppleHealthChartViewController: DataTypeCollectionViewController {
    private let contract = Contracts.appleHealth
	private let fromDate = Date.from(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)!

	private var preferences = UserPreferences.shared()
	private var records = [FitnessActivitySummary]()
	private var sections = [(date: Date, records: [FitnessActivitySummary])]()
	private var digiMe: DigiMe!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setContainerView(self.view)
        configureNavigationBar()
        configureClient()
    }
    
    // MARK: - Private
    
    private func reload() {
        reloadData()
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: nil)
        title = "Result"
        
        var items: [UIBarButtonItem] = []
		
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(showLog), for: .touchUpInside)
		items.append(UIBarButtonItem(customView: infoButton))
                          
#if targetEnvironment(simulator)
        items.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTestData)))
#endif
        navigationItem.rightBarButtonItems = items
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
    
    private func backToInitial(sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
	private func fetchData() {
		SVProgressHUD.show(withStatus: "Fetching data...")
		let credentials = preferences.credentials(for: contract.identifier)
		var sourceAccount: SourceAccount?
		
		digiMe.authorize(credentials: credentials, serviceId: DeviceOnlyServices.appleHealth.rawValue) { result in
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.contract.identifier)
				
				let types: [QuantityType] = [.stepCount, .activeEnergyBurned, .distanceWalkingRunning]
				let anchorDate = self.createAnchorDate(from: self.fromDate)
				let intervalComponents = DateComponents(day: 1)
				let healthConfiguration = HealthKitConfiguration(typesToRead: types, typesToWrite: [], startDate: self.fromDate, endDate: Date(), anchorDate: anchorDate, mergeResultForSameType: false, singleCallbackForAllTypes: true, intervalComponents: intervalComponents)
				
				self.digiMe.appleHealthStatisticsCollectionQuery(for: self.contract.identifier, queryConfig: healthConfiguration) { account in
					sourceAccount = account
					print("Apple Health account: \(String(describing: account))")
				} completion: { stats, error in
					SVProgressHUD.dismiss()
					
					guard
						error == nil,
						let account = sourceAccount else {
						
						self.showPopUp(message: error?.localizedDescription)
						return
					}
					
					let result = self.process(statistics: stats!, for: account)
					
					/// Split data into calendar one week range.
					let chunked = result.chunked(into: 7)
					self.data.append(contentsOf: chunked)
					DispatchQueue.main.async { [weak self] in
						self?.reload()
					}
					
					/// For debugging purposes only.
					/// Group data to monthly time shard
					self.records = result
					self.updateSections()
				}
				
			case.failure(let error):
				self.showPopUp(message: "Authorization failed: \(error)")
			}
		}
	}

    private func updateSections() {
        sections = records
            .sorted { $0.endDate > $1.endDate }
            .groupedBy(dateComponents: [.year, .month])
            .map { ($0, $1) }
            .sorted { $0.0 > $1.0 }
    }
    
    private func showPopUp(message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "digi.me SDK", message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
	/// Response result returns individual object for every type. In the chart we need to manipulate on a daily level.. Lets reduce three times the number of objects.
	private func process(statistics: [Statistics], for account: SourceAccount) -> [FitnessActivitySummary] {
		var result: [FitnessActivitySummary] = []
		
		/// Group incoming data to a daily interval.
		let groupDic = Dictionary(grouping: statistics) { stat -> DateComponents in
			let date = Calendar.current.dateComponents([.day, .year, .month], from: (Date(timeIntervalSince1970: stat.startTimestamp)))
			return date
		}
		
		groupDic.values.forEach { array in
			var steps = 0.0
			var distance = 0.0
			var calories = 0.0
			var startDate: Date!
			var endDate: Date!
			
			array.forEach { stat in
				startDate = Date(timeIntervalSince1970: stat.startTimestamp)
				endDate = Date(timeIntervalSince1970: stat.endTimestamp)
				
				if stat.identifier == HKQuantityTypeIdentifier.stepCount.rawValue {
					steps = stat.harmonized.summary ?? 0.0
				}
				
				if stat.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
					distance = stat.harmonized.summary ?? 0.0
				}
				
				if stat.identifier == HKQuantityTypeIdentifier.activeEnergyBurned.rawValue {
					calories = stat.harmonized.summary ?? 0.0
				}
			}
			
			let distances = FitnessActivitySummary.Distances(activity: "total", distance: distance)
			let activity = FitnessActivitySummary(startDate: startDate, endDate: endDate, steps: steps, distances: [distances], calories: calories, activity: 0, account: account)
			result.append(activity)
		}
		
		result = result.sorted { (($0.startDate).compare($1.startDate)) == .orderedDescending }
		return result
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
	
	@objc private func showLog() {
        let reduced = data.reduce(into: [FitnessActivitySummary]()) { result, value in
            result.append(contentsOf: value)
        }
		let contentView = AppleHealthDetailsView(reduced)
		let controller = UIHostingController(rootView: contentView)
		let navController = UINavigationController(rootViewController: controller)
		navController.setNavigationBarHidden(false, animated: false)
		let doneButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.dismissDetailsView))
		controller.navigationItem.rightBarButtonItem = doneButton
		present(navController, animated: true)
	}
	
	@objc func dismissDetailsView() {
		navigationController?.dismiss(animated: true, completion: nil)
	}
}

#if targetEnvironment(simulator)
extension AppleHealthChartViewController {
    /// iOS Simulator doesn't have any health data by default.
    /// Here we create some basic random data.
    @objc private func addTestData() {
        SVProgressHUD.show(withStatus: "Adding test data...")
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
            
            digiMe.saveHealthData(dataToSave: dataToWrite) { result in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    var message = String()
                    switch result {
                    case .success(let success):
                        message = "Data is \(success ? "saved" : "NOT saved"), \(counter) samples added."
                    case .failure(let error):
                        message = "An error occured saving test data: \(error)"
                    }
                    
                    let alert = UIAlertController(title: "digi.me SDK", message: message, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .cancel) { _ in
                        self.fetchData()
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
#endif
