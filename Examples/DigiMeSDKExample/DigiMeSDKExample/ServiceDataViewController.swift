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
    @IBOutlet private var authWithoutServiceButton: UIButton!
    
    @IBOutlet private var servicesLabel: UILabel!
    @IBOutlet private var addServiceButton: UIButton!
    @IBOutlet private var refreshDataButton: UIButton!
    @IBOutlet private var deleteUserButton: UIButton!
    
    @IBOutlet private var loggerTextView: UITextView!
    
    private var digiMe: DigiMe!
    private var logger: Logger!
    private var currentContract: Contract!
    private let credentialCache = CredentialCache()
    
    private var accounts = [SourceAccount]()
    private var selectServiceCompletion: ((Service?) -> Void)?
    
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
    
    @IBAction private func authorizeWithService() {
        selectService { service in
            guard let service = service else {
                return
            }
            
            self.authorizeAndReadData(service: service)
        }
    }
    
    @IBAction private func authorizeWithoutService() {
        authorizeAndReadData(service: nil)
    }
    
    @IBAction private func addService() {
        guard let credentials = credentialCache.credentials(for: currentContract.identifier) else {
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
                    self.credentialCache.setCredentials(newOrRefreshedCredentials, for: self.currentContract.identifier)
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
        guard let credentials = credentialCache.credentials(for: currentContract.identifier) else {
            self.logger.log(message: "Current contract must be authorized first.")
            return
        }
        
        digiMe.deleteUser(credentials: credentials) { error in
            self.credentialCache.setCredentials(nil, for: self.currentContract.identifier)
            if let error = error {
                self.logger.log(message: "Deleting user failed: \(error)")
            }
            
            self.accounts = []
            self.logger.reset()
            self.updateUI()
        }
    }
    
    @IBAction private func changeScope() {
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = stBoard.instantiateViewController(withIdentifier: "scopeTableViewController")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backButtonTitle = "Back"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setContract(_ contract: Contract) {
        if contract.identifier == currentContract?.identifier {
            return
        }
        
        currentContract = contract
        accounts = []
        do {
            let config = try Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey)
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
        if credentialCache.credentials(for: currentContract.identifier) != nil {
            authWithServiceButton.isHidden = true
            authWithoutServiceButton.isHidden = true
            servicesLabel.isHidden = false
            addServiceButton.isHidden = false
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
            authWithoutServiceButton.isHidden = false
            authWithServiceButton.isHidden = false
            servicesLabel.isHidden = true
            addServiceButton.isHidden = true
            refreshDataButton.isHidden = true
            deleteUserButton.isHidden = true
        }
    }
    
    private func authorizeAndReadData(service: Service?) {
        let credentials = credentialCache.credentials(for: currentContract.identifier)
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
        
        digiMe.authorize(credentials: credentials, serviceId: service?.identifier, readOptions: service?.options) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.credentialCache.setCredentials(newOrRefreshedCredentials, for: self.currentContract.identifier)
                self.updateUI()
                self.getData(credentials: newOrRefreshedCredentials)
                
            case.failure(let error):
                self.logger.log(message: "Authorization failed: \(error)")
            }
        }
    }
    
    private func selectService(completion: @escaping ((Service?) -> Void)) {
        digiMe.availableServices(contractId: currentContract.identifier) { result in
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
        digiMe.readAccounts { result in
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
        digiMe.requestDataQuery(credentials: credentials, readOptions: nil) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.credentialCache.setCredentials(refreshedCredentials, for: self.currentContract.identifier)
                completion(refreshedCredentials)
                
            case.failure(let error):
                self.logger.log(message: "Authorization failed: \(error)")
            }
        }
    }

    private func getServiceData(credentials: Credentials) {
        digiMe.readAllFiles(credentials: credentials, readOptions: nil, resultQueue: .global()) { result in
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
                self.credentialCache.setCredentials(refreshedCredentials, for: self.currentContract.identifier)
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
