//
//  ServiceDataViewController.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

class ServiceDataViewController: UIViewController {
    
    @IBOutlet private var contractLabel: UILabel!
    @IBOutlet private var authWithServiceButton: UIButton!
    
    @IBOutlet private var servicesLabel: UILabel!
    @IBOutlet private var addServiceButton: UIButton!
    @IBOutlet private var contractDetailsButton: UIButton!
    @IBOutlet private var refreshDataButton: UIButton!
    @IBOutlet private var deleteUserButton: UIButton!
    
    @IBOutlet private var loggerTextView: UITextView!
    
    private var digiMe: DigiMe!
    private var logger: Logger!
    private var currentContract: DigimeContract!
	private var preferences = UserPreferences.shared()
    private var accounts = [SourceAccount]()
    private var selectServiceCompletion: ((Service?) -> Void)?
	private var fromDate: Date {
		return Calendar.current.date(byAdding: .month, value: -1, to: Date())!
	}
	private lazy var readOptions: ReadOptions? = {
		let timeRange = TimeRange.after(from: fromDate)
		let scope = Scope(timeRanges: [timeRange])
		return ReadOptions(scope: scope)
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Service Data Example"
        
        logger = Logger(textView: loggerTextView)
        logger.log(message: "This is where log messages appear.")
        
        setContract(Contracts.finSocMus)
    }
    
    @IBAction private func editContract() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Choose contract", message: "", preferredStyle: .alert)
            alert.addAction(.init(title: Contracts.finSocMus.name, style: .default) { _ in
                self.setContract(Contracts.finSocMus)
            })
            
            alert.addAction(.init(title: Contracts.fitHealth.name, style: .default) { _ in
                self.setContract(Contracts.fitHealth)
            })
            
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func showContractDetails() {
        digiMe.contractDetails { result in
            switch result {
            case .success(let certificate):
                DispatchQueue.main.async {
                    let startDate = Date.from(year: 2020, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
                    let endDate = Date.from(year: 2023, month: 12, day: 31, hour: 23, minute: 59, second: 59)!
                    var message = "Example where the data request will be always limited to the contract's time range."
                    message += "\n\tRequested dates start: \(startDate) end: \(endDate)"
                    let timeRange = TimeRange.between(from: startDate, to: endDate)
                    let scope = Scope(timeRanges: [timeRange])
                    let readOptions = ReadOptions(limits: nil, scope: scope)
                    let rangeResult = certificate.verifyTimeRange(readOptions: readOptions)
                    switch rangeResult {
                    case .success(let verified):
                        message += "\n\tVerified start: \(verified.startDate) end: \(verified.endDate)"
                    case .failure(let error):
                        message += "\n\tError verifying time range: \(error.description)"
                    }
                    message += "\n\tContract's certificate: \(certificate.json)"
                    self.logger.log(message: message)
                }
            case .failure(let error):
                self.logger.log(message: "\n\tUnable to retrieve contract details: \(error)")
            }
        }
    }
    
    @IBAction private func authorizeWithService() {
        selectService { service in
            guard let service = service else {
                return
            }
            
            self.authorizeAndReadData(service: service)
        }
    }
    
    @IBAction private func addService() {
        guard let credentials = preferences.credentials(for: currentContract.identifier) else {
            self.logger.log(message: "Current contract must be authorized first.")
            return
        }
        
        selectService { service in
            guard let service = service else {
                return
            }
            
            self.digiMe.addService(identifier: service.identifier, credentials: credentials) { result in
                switch result {
                case .success(let newOrRefreshedCredentials):
					self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.currentContract.identifier)
                    self.getData(credentials: newOrRefreshedCredentials)
                    
                case.failure(let error):
                    self.logger.log(message: "Adding \(service.name) failed: \(error)")
                }
            }
        }
    }
    
    @IBAction private func refreshData() {
        authorizeAndReadData(service: nil)
    }
    
    @IBAction private func deleteUser() {
        guard let credentials = preferences.credentials(for: currentContract.identifier) else {
            self.logger.log(message: "Current contract must be authorized first.")
            return
        }
        
        digiMe.deleteUser(credentials: credentials) { error in
            
            if let error = error {
                self.logger.log(message: "Deleting user failed: \(error)")
            }
            else {
                self.preferences.clearCredentials(for: self.currentContract.identifier)
                self.accounts = []
                self.logger.reset()
                self.updateUI()
            }
        }
    }
    
    private func setContract(_ contract: DigimeContract) {
        if contract.identifier == currentContract?.identifier {
            return
        }
        
        currentContract = contract
        accounts = []
        do {
            let config = try Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true)
            digiMe = DigiMe(configuration: config)
            
            updateUI()
        }
        catch {
            logger.log(message: "Unable to configure digi.me SDK: \(error)")
        }
    }
    
    private func updateUI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateUI()
            }
            
            return
        }
        
        contractLabel.text = "Contract: \(currentContract.name ?? currentContract.identifier)"
        if preferences.credentials(for: currentContract.identifier) != nil {
            authWithServiceButton.isHidden = true
            servicesLabel.isHidden = false
            addServiceButton.isHidden = false
            contractDetailsButton.isHidden = false
            deleteUserButton.isHidden = false
            refreshDataButton.isHidden = false
            
            var servicesText = "Services:"
            if accounts.isEmpty {
                servicesText += "\n\tNone"
            }
            else {
                accounts.forEach { account in
                    servicesText += "\n\t\(account.service.name)"
                    if let name = account.name {
                        servicesText += " - \(name)"
                    }
                }
            }
            
            servicesLabel.text = servicesText
        }
        else {
            authWithServiceButton.isHidden = false
            servicesLabel.isHidden = true
            addServiceButton.isHidden = true
            contractDetailsButton.isHidden = false
            refreshDataButton.isHidden = true
            deleteUserButton.isHidden = true
        }
    }
    
    private func authorizeAndReadData(service: Service?) {
        let credentials = preferences.credentials(for: currentContract.identifier)
        DispatchQueue.main.async {
            var message = "\n\nScope:"
            if let group = service?.options?.scope?.serviceGroups?.first {
                group.serviceTypes.forEach { serviceType in
                    message += "\nFor Service id: \(serviceType.identifier)"
                    message += "\nThe following object types will be returned:"
                    serviceType.serviceObjectTypes.forEach { objectType in
                        message += "\nObject Type: \(objectType.name ?? "n/a")"
                    }
                }
            }
            
            if let timeRanges = self.currentContract.timeRanges {
                message += "\n\nContract Time Ranges:"
                timeRanges.forEach { timeRange in
                    switch timeRange {
                    case let .between(from: from, to: to):
                        message += "\nBetween date: \(from) and \(to)"
                    case let .after(from: from):
                        message += "\nAfter date: \(from)"
                    case let .before(to: to):
                        message += "\nBefore date: \(to)"
                    case let .last(amount: amount, unit: unit):
                        message += "\nLast \(amount)\(unit.rawValue)"
                    }
                }
            }
            
            self.logger.log(message: message)
        }
		
		digiMe.authorize(credentials: credentials, serviceId: service?.identifier, readOptions: readOptions) { result in
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.currentContract.identifier)
				self.updateUI()
				self.getData(credentials: newOrRefreshedCredentials)
				
			case.failure(let error):
				self.logger.log(message: "Authorization failed: \(error)")
			}
		}
	}
    
    private func selectService(completion: @escaping ((Service?) -> Void)) {
        digiMe.availableServices(contractId: currentContract.identifier, filterAvailable: false) { result in
            switch result {
            case .success(let servicesInfo):
                self.selectServiceCompletion = completion
                DispatchQueue.main.async {
                    let vc = ServicePickerViewController(servicesInfo: servicesInfo)
                    vc.delegate = self
                    let nc = UINavigationController(rootViewController: vc)
                    self.present(nc, animated: true, completion: nil)
                }
                
                return
            case .failure(let error):
                self.logger.log(message: "Unable to retrieve services: \(error)")
            }
        }
    }
    
    private func getData(credentials: Credentials) {
        getAccounts(credentials: credentials) { updatedCredentials in
            self.getServiceData(credentials: updatedCredentials)
        }
    }
    
	private func getAccounts(credentials: Credentials, completion: @escaping (Credentials) -> Void) {
		digiMe.readAccounts(credentials: credentials) { result in
			switch result {
			case .success(let accountsInfo):
				self.accounts = accountsInfo.accounts
				self.updateUI()
				completion(credentials)
			case .failure(let error):
				if case .failure(.invalidSession) = result {
					// Need to create a new session
					self.requestDataQuery(credentials: credentials) { refreshedCredentials in
						self.getAccounts(credentials: refreshedCredentials, completion: completion)
					}
					return
				}
				
				self.logger.log(message: "Error retrieving accounts: \(error)")
			}
		}
	}
    
    private func requestDataQuery(credentials: Credentials, completion: @escaping (Credentials) -> Void) {
        digiMe.requestDataQuery(credentials: credentials, readOptions: readOptions) { result in
            switch result {
            case .success(let refreshedCredentials):
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.currentContract.identifier)
                completion(refreshedCredentials)
                
            case.failure(let error):
                self.logger.log(message: "Authorization failed: \(error)")
            }
        }
    }

    private func getServiceData(credentials: Credentials) {
        digiMe.readAllFiles(credentials: credentials, readOptions: readOptions, resultQueue: .global()) { result in
            switch result {
            case .success(let file):
                
                var message = "Downloaded file \(file.identifier)"
                switch file.metadata {
                case .mapped(let metadata):
                    message += "\n\tService group: \(metadata.serviceGroup)"
                    message += "\n\tService name: \(metadata.serviceName)"
                    message += "\n\tObject type: \(metadata.objectType)"
                    message += "\n\tItem count: \(metadata.objectCount)"
                default:
                    message += "\n\tUnexpected metadata"
                }
                
                if
                    let fileInJson = file.toJSON() as? [[String: Any]],
                    var jfsWithMetadata = file.dictionary as? [String: Any] {
                    
                    jfsWithMetadata["data"] = fileInJson
                    FilePersistentStorage(with: .documentDirectory).store(object: jfsWithMetadata, fileName: file.identifier)
                }
                
                message += "\nUpdated: \(file.updatedDate)"
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading file: \(error)")
            }
        } completion: { result in
            switch result {
            case .success(let (fileList, refreshedCredentials)):
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.currentContract.identifier)
                var message = "Finished reading files:"
                fileList.files?.forEach { message += "\n\t\($0.name)" }
                message += "\n\nFiles in the list: \(fileList.files?.count ?? 0)"
                message += "\nSync state: \(fileList.status.state.rawValue)"
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading files: \(error)")
            }
        }
    }
}

extension ServiceDataViewController: ServicePickerDelegate {
    func didSelectService(_ service: Service?) {
        selectServiceCompletion?(service)
        selectServiceCompletion = nil
    }
}
