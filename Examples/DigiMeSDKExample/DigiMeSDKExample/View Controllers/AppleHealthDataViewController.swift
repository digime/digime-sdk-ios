//
//  AppleHealthDataViewController.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import HealthKit
import SVProgressHUD
import UIKit

class AppleHealthDataViewController: DataTypeCollectionViewController {
        
    private var records = [FitnessActivity]()
    private var sections = [(date: Date, records: [FitnessActivity])]()
    private var digiMe: DigiMe!
    private let credentialCache = CredentialCache()
    private let contract = Contracts.appleHealth
    private lazy var readOptions: ReadOptions? = {
        /// In this version of the SDK, the only supported object type is 'Fitness Activity'.
        /// This example is for demonstration purposes only.
        let objectType = ServiceObjectType(identifier: 300, name: "Fitness Activity")
        let services = [ServiceType(identifier: 28, objectTypes: [objectType])]
        let groups = [ServiceGroupScope(identifier: 4, serviceTypes: services)]
        /// Time ranges allow you to narrow down the contract's time scope.
        /// For example: if your contract allows you to gather data within one year
        /// then using the scope object you can get data for a month or for one day only, etc.
        let timeRange = TimeRange.last(amount: 112, unit: TimeRange.Unit.day)
        let scope = Scope(serviceGroups: groups, timeRanges: [timeRange])
       return ReadOptions(limits: nil, scope: scope)
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setContainerView(self.view)
        configureNavigationBar()
        
        /// On load: - initialize client, authorize or fetch data.
        configureClient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private
    
    private func reload() {
        reloadData()
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: nil)
        title = "Steps & Distance"
        
        var items: [UIBarButtonItem] = []
        
        if credentialCache.credentials(for: contract.identifier) != nil {
            items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteUser)))
        }
                          
#if targetEnvironment(simulator)
        items.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTestData)))
#endif
        navigationItem.rightBarButtonItems = items
    }
    
    private func configureClient() {
        do {
            /// On initialization create a configuration object with digi.me contract details.
            let config = try Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey)
            digiMe = DigiMe(configuration: config)
            
            if credentialCache.credentials(for: contract.identifier) == nil {
                /// Authorize and fetch data on the first load.
                authorizeContract()
            }
            else {
                /// Fetch fitness data. Use read options to narrow down the fetch request.
                /// Options have to include the date range shorter than your digi.me contract.
                /// Options are optional parameters. If not present it will return data for the whole date range of the contract.
                fetchData(readOptions: readOptions)
            }
        }
        catch {
            SVProgressHUD.dismiss()
            self.showPopUp(message: "Unable to configure digi.me SDK: \(error.localizedDescription)")
        }
    }
    
    private func authorizeContract() {
        SVProgressHUD.show(withStatus: "Authorizing...")
        let credentials = credentialCache.credentials(for: contract.identifier)
        /// Authorise client with credentials. Credentials are optional parameters.
        /// It will create a new session on the first load or it will validate existing for a valid session to fetch new data in the completion block.
        digiMe.authorize(credentials: credentials) { result in
            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let newOrRefreshedCredentials):
                /// Store credentials locally.
                self.credentialCache.setCredentials(newOrRefreshedCredentials, for: self.contract.identifier)
                /// Fetch fitness data. Use read options to narrow down the fetch request.
                /// Options have to include the date range shorter than your digi.me contract.
                self.fetchData(readOptions: self.readOptions)
                
            case.failure(let error):
                self.showPopUp(message: "Authorization failed: \(error.description)")
            }
        }
    }
    
    private func backToInitial(sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func fetchData(readOptions: ReadOptions? = nil) {
        guard let credentials = credentialCache.credentials(for: contract.identifier) else {
            authorizeContract()
            return
        }
        
        SVProgressHUD.show(withStatus: "Fetching data...")
        
        digiMe.retrieveAppleHealth(readOptions: readOptions, credentials: credentials) { result in
            SVProgressHUD.dismiss()

            switch result {
            case .success(let healthResult):
                
                /// For debugging purpose only.
                /// Debugging account data.
                if
                    let account = healthResult.account,
                    let jsonData = try? account.encoded(dateEncodingStrategy: .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase) {
                    
                    print(account.dictionary.debugDescription)
                    FilePersistentStorage(with: .documentDirectory).store(data: jsonData, fileName: "account.json")
                }
                
                /// Split data into calendar one week range.
                let chunked = healthResult.data.chunked(into: 7)
                self.data.append(contentsOf: chunked)
                DispatchQueue.main.async { [weak self] in
                    self?.reload()
                }
                
                /// For debugging purposes only.
                /// Group data to monthly time shard
                self.records = healthResult.data
                self.updateSections()
                
                /// Store the data content locally. Use iTunes file sharing to review JFS data saved under the Documents folder.
                self.saveToJFS()
                
            case .failure(let error):
                switch error {
                case .invalidSession:
                    /// The session is invalid. Clear local copy and trigger the new authorization routine.
                    self.credentialCache.clearCredentials(for: self.contract.identifier)
                    self.authorizeContract()
                default:
                    self.showPopUp(message: error.description)
                }
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
    
    private func showPopUp(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "digi.me SDK", message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    private func saveToJFS() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMM"
        for month in self.sections {
            
            if
                let endDate = month.records.last?.endDate,
                let jsonData = try? month.records.encoded(dateEncodingStrategy: .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase) {
                let filename = "18_4_28_3_300_D\(formatter.string(from: endDate))_0.json"
                FilePersistentStorage(with: .documentDirectory).store(data: jsonData, fileName: filename)
            }
        }
    }
    
    /// Clear all data locally and remotely.
    /// The current version does not upload Apple health data to digime backend.
    /// Only remote Session objects will be cleared.
    @objc private func deleteUser() {
        guard let credentials = credentialCache.credentials(for: contract.identifier) else {
            print("No credentials is available to delete user's data")
            return
        }
        
        SVProgressHUD.show(withStatus: "Deleting credentials...")
        
        digiMe.deleteUser(credentials: credentials) { error in
            SVProgressHUD.dismiss()
            
            var message = String()
            if let error = error {
                message += "Error occured deleting user \(error)"
                print(message)
            }
            else {
                message += "User's credentials and the session are cleared."
                self.credentialCache.clearCredentials(for: self.contract.identifier)
                self.records = []
                self.sections = []
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            self.showPopUp(message: message)
        }
    }
}

#if targetEnvironment(simulator)
extension AppleHealthDataViewController {
    /// iOS Simulator doesn't have any health data by default.
    /// Here we create random data for all time for demo purposes.
    @objc private func addTestData() {
        SVProgressHUD.show(withStatus: "Adding test data...")
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [self] in
            var dataToWrite: [HKQuantitySample] = []
            let startDate = Date(timeIntervalSince1970: 0)
            let endDate = Date().endOfTomorrow
            let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
            var counter: Int = 0
            for date in stride(from: startDate, to: endDate, by: dayDurationInSeconds) {
                let end = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: date)!.endOfDay
                let start = Calendar.utcCalendar.startOfDay(for: end)
                print("Start: \(start) End: \(end)")
                // steps data
                let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
                let stepsQuantity = HKQuantity(unit: .count(), doubleValue: Double.random(in: 1...5000))
                let steps = HKQuantitySample(type: stepsType, quantity: stepsQuantity, start: start, end: end)
                dataToWrite.append(steps)
                
                // distance walking & running
                let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
                let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: Double.random(in: 1...3000))
                let walk = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: start, end: end)
                dataToWrite.append(walk)
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
                        self.fetchData(readOptions: self.readOptions)
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
#endif
