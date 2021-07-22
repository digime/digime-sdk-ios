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
    
    @IBOutlet private var authInfoLabel: UILabel!
    @IBOutlet private var authWithServiceButton: UIButton!
    @IBOutlet private var authWithoutServiceButton: UIButton!
    
    @IBOutlet private var servicesLabel: UILabel!
    @IBOutlet private var addServiceButton: UIButton!
    @IBOutlet private var refreshDataButton: UIButton!
    @IBOutlet private var deleteUserButton: UIButton!
    
    @IBOutlet private var loggerTextView: UITextView!
    
    private var digiMe: DigiMe!
    private var configuration: Configuration?
    private var logger: Logger!
    
    private var accounts = [Account]()
    private var selectServiceCompletion: ((Service?) -> Void)?
    
    private enum ContractInfo {
        // This contract is a one-off contract which allows SDK user to read user's Spotify
        // data from the past 6 months user over multiple sessions.
        // User consent is required just once (via digi.me app).
        static let contractId = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        static let privateKey = """
MIIEowIBAAKCAQEAvup5e4PbVBVNHtRosFXPPvZCO1kNySe9qo2zI+QnHk7jyK2Y
11MGJiVLkxKp02bGV4NlK5ASptLH22imPSYP/INE1p+XxcSIth1rFZy0b/aWDktM
SB5KMWhIhcmcjLqTuQ8q6qQFDhRVUfBtgbTz64LQ29IHc5EBSN4XzMYwnybbJ6ye
hR5IHoZugRkZA/HZadlPpnygIIN9X2TcuNGaaNh8yum6Jl9xLKpid4CzACTc3Gxg
wdn9o05nzYndnYJqwo2QxreCXifuCZTpjhFW42dqtdRc5YyWFgf1Q8WuaGhBQBNb
P62NLLNUm194IOSUZMl0B8/PYyFjgKmI2M1GEQIDAQABAoIBAE1jstb0vkW5VMe4
hq9kOVxmarawBLyT1Xh7dDCKXakVhZRlel1elFGGMLpviFPfh2sWIj6kakshik5Q
f4KuGTDc7Vyq2NUcM+bOyge6vBHevTkSINvjG2Qnx64j6cfKIfOUSGtRDZOFfoh2
k41OksnW/178JnUcRI8LKE6j0DXS0NcZ//ToJMkYVqCuBqSE0TjX7VXL9Vad9D9v
P4UYjC3ZX8InRCd8akzwhi7x9nZf0zvGtXemEuVOYkOJMLg3ZheYKPpHZgO6Tqhi
tYiwa+YSr6VJ5WvlLFy3LTkwsWg/gdT4JNCV6X/rWrU4JXnJIgdgVgIM+4bwSoFv
I9D7zAECgYEA6vIkmdUOv7SDzgfn4w9MgvePGTYZZDbcYPOM0qhDhY0OJhXMgc6L
hiB6+xvm8HnEfGdbak7eYyTZ/Z7Oe2YxDl9pYGZ3AQAKbDT7liuDQGZWRMUYdGtA
2mRjIi99P8ufeXXLrTwPIk/MPldfd6+dCEZ3mB8sM4T0mSo4kKfdi7ECgYEA0AY/
RdInONgfuzvDf1w9+vsxRaDsWUdiDGRo04nqNlTduxqTSDKCoLMUS6EipANMuOxO
rmxlXfvF7GPaWj4tgrYR0QeJLhk2ScdTe2apGkLgfLnPovaAxPIneaF+xoaSwhSx
PRt4sygYxB6fNQ7KMvofPETPprMt4AC9H5Ve2GECgYAiLcPBVUtl/B7IlEHZuFoL
G3SH2GTtPUXmHMg5xRy9iv2p8LXllGSbyJHbgf2gsjYxWt/joUGc7rl/ueCT9xPf
4WV1DrL1REo/351SBVZ8weZ+7qVWGlw+6Se6y2nPJBI5GzfcJcaV2UH/N7q9sKCJ
mabATJijjg3/UjMUaDdEoQKBgQCRWcwcHRsKvPhu+vM+qlUkaR+kZyy9tQLtZbtZ
E6RzEhlcAtWmPKTJZFdqAM0TjLqu+25+sX6ijKle4uZO5+Mk0dLhG0Le0v77ziqm
rrS5hMEWZT6Pv216Lzkl45GRZbZlpc+xwuAzTnD/l+XmTM87j0kD85CkCc6kFeAP
kW8UAQKBgFv91+8v1pFlPGgbwT3NFM/z9CIbjTl+5wAzvSPO8q2tGXDBO2dpt+2U
XTB5irocXRj2XXn1sMpGBJGf4AKRrIhQNIoAhouh7btYBAD7+eT8SlGQ75wKkaDW
u3W6P+D7xkopNDDFki7IcLyaRzKvXjGf8HeKz0YP+XomHb25Bc3A
"""
    }
    
    private var authorizedDate: Date? {
        get {
            guard let timestamp = UserDefaults.standard.object(forKey: "\(ContractInfo.contractId).authorizedDate") as? Double else {
                return nil
            }
            
            return Date(timeIntervalSince1970: timestamp)
        }
        
        set {
            UserDefaults.standard.setValue(newValue?.timeIntervalSince1970, forKey: "\(ContractInfo.contractId).authorizedDate")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Service Data Example"
        
        logger = Logger(textView: loggerTextView)
                
        logger.log(message: "This is where log messages appear.")
        
        let config = Configuration(appId: AppInfo.appId, contractId: ContractInfo.contractId, privateKey: ContractInfo.privateKey)
        digiMe = DigiMe(configuration: config)
        configuration = config
                
        updateUI()
    }
    
    @IBAction private func authorizeWithService() {
        selectService { service in
            guard let service = service else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Please select try again and select a service", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            self.authorizeAndReadData(service: service)
        }
    }
    
    @IBAction private func authorizeWithoutService() {
        authorizeAndReadData(service: nil)
    }
    
    @IBAction private func addService() {
        selectService { service in
            guard let service = service else {
                return
            }
            
            self.digiMe.addService(identifier: service.identifier) { error in
                if let error = error {
                    self.logger.log(message: "Adding \(service.name) failed: " + error.localizedDescription)
                    return
                }
                
                self.getAccounts()
                self.getServiceData()
            }
        }
    }
    
    @IBAction private func refreshData() {
        authorizeAndReadData(service: nil)
    }
    
    @IBAction private func deleteUser() {
        digiMe.deleteUser { error in
            if let error = error {
                self.logger.log(message: "Deleting user failed: " + error.localizedDescription)
                return
            }
            
            self.authorizedDate = nil
            self.accounts = []
            self.logger.reset()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateUI()
            }
            
            return
        }
        
        if digiMe.isConnected {
            
            if let date = authorizedDate {
                authInfoLabel.text = "Authorized on \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))"
            }
            else {
                authInfoLabel.text = "Authorized"
            }
            
            authWithServiceButton.isHidden = true
            authWithoutServiceButton.isHidden = true
            servicesLabel.isHidden = false
            addServiceButton.isHidden = false
            deleteUserButton.isHidden = false
            
            var servicesText = "Services:"
            if accounts.isEmpty {
                servicesText += "\n\tNone"
                refreshDataButton.isHidden = true
            }
            else {
                accounts.forEach { account in
                    servicesText += "\n\(account.service.name) - \(account.name)"
                }
                refreshDataButton.isHidden = false
            }
            
            servicesLabel.text = servicesText
        }
        else {
            authInfoLabel.text = "You haven't authorized this contract yet."
            authWithoutServiceButton.isHidden = false
            authWithServiceButton.isHidden = false
            servicesLabel.isHidden = true
            addServiceButton.isHidden = true
            refreshDataButton.isHidden = true
            deleteUserButton.isHidden = true
        }
    }
    
    private func authorizeAndReadData(service: Service?) {
        self.digiMe.authorize(serviceId: service?.identifier, readOptions: nil) { error in
            if let error = error {
                self.logger.log(message: "Authorization failed: \(error)")
                return
            }
            
            if self.authorizedDate == nil {
                self.authorizedDate = Date()
            }
            
            self.updateUI()
            self.getAccounts()
            self.getServiceData()
        }
    }
    
    private func selectService(completion: @escaping ((Service?) -> Void)) {
        digiMe.availableServices(scope: .thisContractOnly) { result in
            switch result {
            case .success(let servicesInfo):
                self.selectServiceCompletion = completion
                DispatchQueue.main.async {
                    let vc = ServicePickerViewController(services: servicesInfo.services)
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
        
    private func resetClient() {
        let config = Configuration(appId: AppInfo.appId, contractId: ContractInfo.contractId, privateKey: ContractInfo.privateKey)
        digiMe = DigiMe(configuration: config)
        configuration = config
    }
    
    private func getAccounts() {
        digiMe.readAccounts { result in
            switch result {
            case .success(let accountsInfo):
                self.accounts = accountsInfo.accounts
                self.updateUI()
            case .failure(let error):
                self.logger.log(message: "Error retrieving accounts: \(error)")
            }
        }
    }

    private func getServiceData() {
        digiMe.readFiles(readOptions: nil) { result in
            switch result {
            case .success(let fileContainer):
                var message = "Downloaded file \(fileContainer.identifier)"
                if let metadata = fileContainer.metadata {
                    message += "\n\tService group: \(metadata.serviceGroup)"
                    message += "\n\tService name: \(metadata.serviceName)"
                    message += "\n\tObject type: \(metadata.objectType)"
                    message += "\n\tItem count: \(metadata.objectCount)"
                }
                
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading file: \(error)")
            }
        } completion: { result in
            switch result {
            case .success(let fileList):
                var message = "Finished reading files:"
                fileList.files.forEach { message += "\n\t\($0.name)" }
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
