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
    private let credentialCache = CredentialCache()
    private let serialQueue = DispatchQueue(label: "ImportSerializationQueue")
    weak var delegate: DigiMeServiceDelegate?
    
    var isConnected: Bool {
        credentials != nil
    }
    
    private var credentials: Credentials? {
        get {
            credentialCache.credentials(for: AppCoordinator.configuration.contractId)
        }
        set {
            credentialCache.setCredentials(newValue, for: AppCoordinator.configuration.contractId)
        }
    }
    
    init(client: DigiMe, repository: ImportRepository) {
        dmeClient = client
        self.repository = repository
    }
    
    func authorize(readOptions: ReadOptions?, serviceId: Int? = nil, completion: @escaping (SDKError?) -> Void) {
        dmeClient.authorize(credentials: credentials, serviceId: serviceId, readOptions: readOptions) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.credentials = newOrRefreshedCredentials
                completion(nil)
                
            case.failure(let error):
                completion(error)
            }
        }
    }
    
    func getAccounts() {
        dmeClient.readAccounts() { result in
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
        guard let credentials = credentials else {
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
            case .success(let (_, refreshedCredentials)):
                self.credentials = refreshedCredentials
                
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
        guard let credentials = credentials else {
            print("Attempting to delete user before authorizing contract")
            return
        }
        
        dmeClient.deleteUser(credentials: credentials) { error in
            self.credentials = nil
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
