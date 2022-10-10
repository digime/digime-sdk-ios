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
    private var fitnessActivityResult: [String: [FitnessActivitySummary]] = [:]
    
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
                    var meta = HealthDataClient.metadata
					meta.message = error.description
					meta.code = "\((error as NSError).code)"
                    Logger.mixpanel("device-data-source-read-failed", metadata: meta)
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
            let error = SDKError.healthDataError(message: "Health Data Processor returned no result")
            var meta = HealthDataClient.metadata
			meta.message = error.description
			meta.code = "\((error as NSError).code)"
            Logger.mixpanel("device-data-source-read-failed", metadata: meta)
            completionHandler?(.failure(error))
            return
        }
        
        var files: [File] = []
        var records = [FitnessActivitySummary]()
        var data: [[FitnessActivitySummary]] = []
        var sections = [(date: Date, records: [FitnessActivitySummary])]()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMM"
        
        let chunked = result.chunked(into: 7)
        data.append(contentsOf: chunked)

        records = result
        sections = records
            .sorted { $0.endDate > $1.endDate }
            .groupedBy(dateComponents: [.year, .month])
            .map { ($0, $1) }
            .sorted { $0.0 > $1.0 }
        
        for month in sections {
            
            if
                let endDate = month.records.last?.endDate,
                let jsonData = try? month.records.encoded(dateEncodingStrategy: .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase) {
                
                let filename = "18_4_28_0_301_D\(formatter.string(from: endDate))_0.json"
                let napped = MappedFileMetadata(objectCount: month.records.count, objectType: "dailyactivity", serviceGroup: "health & fitness", serviceName: "applehealth")
                let meta = FileMetadata.mapped(napped)
                let jfsFile = File(fileWithId: filename, rawData: jsonData, metadata: meta, updated: Date())
                files.append(jfsFile)
            }
        }
        
        let healthResult = HealthResult(account: account, data: result, files: files)
        Logger.mixpanel("device-data-source-read-success", metadata: HealthDataClient.metadata)
        completionHandler?(.success(healthResult))
    }
}
