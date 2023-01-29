//
//  HealthKitFilesDataService.swift
//  DigiMeSDK
//
//  Created on 01/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitFilesDataService {
	private let queue: OperationQueue
	private let healthStore: HKHealthStore
	
    private var kvoToken: NSKeyValueObservation?
    private var account: SourceAccount
    private var processor = FitnessActivityProcessor()
    private var fitnessActivityResult: [String: [FitnessActivitySummary]] = [:]
	private var fileDownloadHandler: ((Result<File, SDKError>) -> Void)?
	private var completionHandler: ((Result<[FileListItem], SDKError>) -> Void)?
	
    // MARK: - Life Cycle
    
	init(account: SourceAccount) {
        self.account = account
		
		healthStore = HKHealthStore()
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
    
	func queryData(from startDate: Date, to endDate: Date, downloadHandler: ((Result<File, SDKError>) -> Void)?, completion: ((Result<[FileListItem], SDKError>) -> Void)?) {
		
		self.fileDownloadHandler = downloadHandler
		self.completionHandler = completion
		
		Logger.mixpanel("device-data-source-read-started", metadata: HealthKitData().metadata)
		
		let dataTypes = FitnessActivityProcessor.defaultTypesToRead
        var operationsToQueue: [Operation] = []
        var parentOperation: HealthKitDataQuantityOperation?
        
        for dataType in dataTypes {
            let operation = HealthKitDataQuantityOperation(from: startDate, to: endDate, with: dataType, healthStore: healthStore, account: account)
            
            let operationCompletion: (Result<HealthDataOperationResult, SDKError>) -> Void = { result in
                switch result {
                case .failure(let error):
					HealthKitService.reportErrorLog(error: error)
                    self.fileDownloadHandler?(.failure(error))
                case .success(let operationResult):
                    self.fitnessActivityResult[dataType.original!.identifier] = operationResult.data[dataType.original!.identifier]
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
			HealthKitService.reportErrorLog(error: error)
			completionHandler?(.failure(error))
            return
        }
        
        var files: [File] = []
        var records = [FitnessActivitySummary]()
        var data: [[FitnessActivitySummary]] = []
        var sections = [(date: Date, records: [FitnessActivitySummary])]()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMM"
		var fileListItems: [FileListItem] = []
		let updated = Date()
		
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
                let mapped = MappedFileMetadata(objectCount: month.records.count, objectType: "dailyactivity", serviceGroup: "health & fitness", serviceName: "applehealth")
                let meta = FileMetadata.mapped(mapped)
                let jfsFile = File(fileWithId: filename, rawData: jsonData, metadata: meta, updated: updated)
				let fileListItem = FileListItem(name: filename, objectVersion: "1", updatedDate: updated)
                files.append(jfsFile)
				fileListItems.append(fileListItem)
				fileDownloadHandler?(.success(jfsFile))
            }
        }
        
		completionHandler?(.success(fileListItems))
        Logger.mixpanel("device-data-source-read-success", metadata: HealthKitData().metadata)
    }
}
