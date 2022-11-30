//
//  HealthDataClient.swift
//  DigiMeSDK
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import HealthKit
import UIKit

class HealthDataClient {
    static var metadata = LogEventMeta(service: ["applehealth"],
									   servicegroup: ["health & fitness"],
									   appname: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
    
    private var healthService: HealthDataService
    
    // MARK: - Life Cycle
    
    init(healthService: HealthDataService) {
        self.healthService = healthService
    }
    
    // MARK: - Retrieve Data
    
    func retrieveData(from startDate: Date, to endDate: Date, accountHandler: @escaping (SourceAccount) -> Void, completion: @escaping (Result<HealthResult, SDKError>) -> Void) {
        Logger.mixpanel("device-data-source-read-started", metadata: HealthDataClient.metadata)
        HealthStore.requestHealthDataAccessIfNeeded() { result in
            switch result {
            case .success(_):
                Logger.mixpanel("device-data-source-read-authorised", metadata: HealthDataClient.metadata)
                accountHandler(HealthDataAccount().account)
                self.loadData(from: startDate, to: endDate, completion: completion)
            case .failure(let error):
                var meta = HealthDataClient.metadata
				meta.message = error.description
				meta.code = "\((error as NSError).code)"
                Logger.mixpanel("device-data-source-read-cancelled", metadata: meta)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Add to Health Store
    
    func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        HealthStore.saveData(data, completion: completion)
    }
    
    // MARK: - Private
    
    private func loadData(from startDate: Date, to endDate: Date, completion: @escaping (Result<HealthResult, SDKError>) -> Void) {
        healthService.queryData(from: startDate, to: endDate)
        healthService.completionHandler = completion
    }
}