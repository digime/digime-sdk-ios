//
//  DigiMeService.swift
//  Genrefy
//
//  Created on 06/04/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit

protocol DigiMeServiceDelegate: AnyObject {
    func serviceDidFinishImporting()
}

class DigiMeService {
    
    let repository: ImportRepository
    private let dmeClient: DigiMe
    private let preferences = UserPreferences.shared()
    private let serialQueue = DispatchQueue(label: "ImportSerializationQueue")
    weak var delegate: DigiMeServiceDelegate?
    
    var isConnected: Bool {
        (preferences.credentials(for: AppCoordinator.configuration.contractId) != nil)
    }
    
    init(client: DigiMe, repository: ImportRepository) {
        dmeClient = client
        self.repository = repository
    }
    
    func authorize(readOptions: ReadOptions?, serviceId: Int? = nil, completion: @escaping (SDKError?) -> Void) {
        let credentials = preferences.credentials(for: AppCoordinator.configuration.contractId)
        
        dmeClient.authorize(credentials: credentials, serviceId: serviceId, readOptions: readOptions) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: AppCoordinator.configuration.contractId)
                completion(nil)
                
            case.failure(let error):
                completion(error)
            }
        }
    }
    
    func getAccounts() {
        guard let credentials = preferences.credentials(for: AppCoordinator.configuration.contractId) else {
            print("Attempting to read data before authorizing contract")
            return
        }
        
        dmeClient.readAccounts(credentials: credentials) { result in
            switch result {
            case .success(let accountsInfo):
                self.serialQueue.sync {
                    self.repository.process(accountsInfo: accountsInfo)
                }
                
            case .failure(let error):
                print("digi.me failed to retrieve accounts with error: \(error)")
            }
        }
    }

    func getSessionData() {
        guard let credentials = preferences.credentials(for: AppCoordinator.configuration.contractId) else {
            print("Attempting to read data before authorizing contract")
            return
        }
        
        dmeClient.readAllFiles(credentials: credentials, readOptions: nil) { result in
            switch result {
            case .success(let file):
                self.serialQueue.sync {
                    self.repository.process(file: file)
                }
                
            case .failure(let error):
                print("digi.me failed to retrieve file with error: \(error)")
            }
        } completion: { result in
            switch result {
            case .success(let (_, newOrRefreshedCredentials)):
                self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: AppCoordinator.configuration.contractId)
                
            case .failure(let error):
                print("digi.me failed to complete getting session data with error: \(error)")
            }
            
            self.serialQueue.sync {
                DispatchQueue.main.async {
                    self.delegate?.serviceDidFinishImporting()
                }
            }
        }
    }
    
    func deleteUser(completion: @escaping (SDKError?) -> Void) {
        guard let credentials = preferences.credentials(for: AppCoordinator.configuration.contractId) else {
            print("Attempting to delete user before authorizing contract")
            return
        }
        
        dmeClient.deleteUser(credentials: credentials) { error in
            self.preferences.clearCredentials(for: AppCoordinator.configuration.contractId)
            completion(error)
        }
    }
    
    func lastDayScope() -> Scope {
        let objects = [ServiceObjectType(identifier: 406)]
        let services = [ServiceType(identifier: 19, objectTypes: objects)]
        let groups = [ServiceGroupScope(identifier: 5, serviceTypes: services)]
        let timeRanges = [TimeRange.last(amount: 1, unit: .day)]
        return Scope(serviceGroups: groups, timeRanges: timeRanges)
    }
}
