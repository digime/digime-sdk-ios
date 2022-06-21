//
//  HealthDataService.swift
//  DigiMeSDK
//
//  Created on 01/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import HealthKit

class HealthDataService {
    var completionHandler: ((Result<HealthResult, SDKError>) -> Void)?
    
    private let queue: OperationQueue
    private var kvoToken: NSKeyValueObservation?
    
    private var account: SourceAccount
    
    private var processor = FitnessActivityProcessor()
    private var fitnessActivityResult: [String: [FitnessActivity]] = [:]
    
    // MARK: - Life Cycle
    
    init(account: SourceAccount) {
        self.account = account
        
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "me.digi.sdk.healthDataService"
        
        kvoToken = queue.observe(\.operationCount, options: .new) { obj, change in
            if change.newValue == 0 {
                self.processAndFinish()
            }
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
    
    // MARK: - Data operations
    
    func queryData(from startDate: Date, to endDate: Date) {
        let dataTypes: [String] = FitnessActivityProcessor.dataTypes
        var operationsToQueue: [Operation] = []
        var parentOperation: HealthDataQuantityOperation?
        
        for dataTypeIdentifier in dataTypes {
            let operation = HealthDataQuantityOperation(from: startDate, to: endDate, with: dataTypeIdentifier, account: account)
            
            let operationCompletion: (Result<HealthDataOperationResult, SDKError>) -> Void = { result in
                switch result {
                case .failure(let error):
                    self.completionHandler?(.failure(error))
                case .success(let operationResult):
                    self.fitnessActivityResult[dataTypeIdentifier] = operationResult.data[dataTypeIdentifier]
                }
            }
            
            operation.operationCompletion = operationCompletion
            
            operationsToQueue.append(operation)
            if let parent = parentOperation {
                operation.addDependency(parent)
            }
            
            parentOperation = operation
        }
        
        queue.addOperations(operationsToQueue, waitUntilFinished: false)
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
    
    // MARK: - Private
    
    private func processAndFinish() {
        guard let result = processor.process(data: fitnessActivityResult) else {
            completionHandler?(.failure(.healthDataError(message: "Health Data Processor returned no result")))
            return
        }
        
        let healthResult = HealthResult(account: account, data: result)
        completionHandler?(.success(healthResult))
    }
}
