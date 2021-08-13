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

    let dmeClient: DigiMe
    let repository: ImportRepository
    private let serialQueue = DispatchQueue(label: "ImportSerializationQueue")
    weak var delegate: DigiMeServiceDelegate?
    
    init(client: DigiMe, repository: ImportRepository) {
        dmeClient = client
        self.repository = repository
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
        dmeClient.readFiles(readOptions: nil) { result in
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
            case .success:
                self.serialQueue.sync {
                    DispatchQueue.main.async {
                        self.delegate?.serviceDidFinishImporting()
                    }
                }
                
            case .failure(let error):
                print("digi.me failed to complete getting session data with error: \(error)")
            }
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
