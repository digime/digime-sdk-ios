//
//  DigiMeService.swift
//  Genrefy
//
//  Created on 06/04/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit

protocol DigiMeServiceDelegate: class {
    func serviceDidFinishImporting()
}

class DigiMeService {

    let dmeClient: DMEPullClient
    let repository: ImportRepository
    private let serialQueue = DispatchQueue(label: "ImportSerializationQueue")
    weak var delegate: DigiMeServiceDelegate?
    
    init(client: DMEPullClient, repository: ImportRepository) {
        dmeClient = client
        self.repository = repository
    }
    
    func getAccounts() {
        dmeClient.getSessionAccounts(completion: { (accounts, error) in
            if let accounts = accounts {
                self.repository.process(accounts: accounts)
            }

            if let error = error {
                print("digi.me failed to retrieve accounts with error: \(error)")
            }
        })
    }

    func getSessionData() {
        dmeClient.getSessionData(downloadHandler: { (file, error) in
            if let file = file {
                self.serialQueue.sync {
                    self.repository.process(file: file)
                }
            }

            if let error = error {
                print("digi.me failed to retrieve file with error: \(error)")
            }
        }, completion: { (fileList, error) in
            if let error = error {
                print("digi.me failed to complete getting session data with error: \(error)")
            }

            self.serialQueue.sync {
                DispatchQueue.main.async {
                    self.delegate?.serviceDidFinishImporting()
                }
            }
        })
    }
    
    func saveToken(_ token: DMEOAuthToken?) {
        guard
            let token = token,
            let tokenData = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false) else {
                print("Could not save OAuthToken")
                return
        }

        print("OAuth access token: " + (token.accessToken ??  "n/a"))
        print("OAuth refresh token: " + (token.refreshToken ?? "n/a"))
        
        KeychainService.shared.saveEntry(data: tokenData, for: "oAuthToken")
    }
    
    func loadToken() -> DMEOAuthToken? {
        guard
            let tokenData = KeychainService.shared.loadEntry(for: "oAuthToken"),
            let token = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(tokenData) as? DMEOAuthToken else {
                print("Could not load OAuthToken")
                return nil
        }
        
        print("OAuth access token: " + (token?.accessToken ?? "n/a"))
        print("OAuth refresh token: " + (token?.refreshToken ?? "n/a"))
        return token
    }
    
    func lastDayScope() -> DMEScope {
        let scope = DMEScope()
        let objects = [DMEServiceObjectType(identifier: 406)]
        let services = [DMEServiceType(identifier: 19, objectTypes: objects)]
        let groups = [DMEServiceGroup(identifier: 5, serviceTypes: services)]
        scope.serviceGroups = groups
        scope.timeRanges = [DMETimeRange.last(1, unit: .day)]
        return scope
    }
}
