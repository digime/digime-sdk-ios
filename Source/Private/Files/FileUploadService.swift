//
//  FileUploadService.swift
//  DigiMeSDK
//
//  Created on 08/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class FileUploadService {
    private let queue: OperationQueue
    private let apiClient: APIClient
    private let configuration: Configuration
        
    init(apiClient: APIClient, configuration: Configuration) {
        self.apiClient = apiClient
        self.configuration = configuration
        
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "me.digi.sdk.fileuploadservice"
    }
    
    func uploadFile(data: Data, metadata: Data, credentials: Credentials, completion: @escaping (Result<Session, SDKError>) -> Void) {
        let operation = FileUploadOperation(data: data, metadata: metadata, credentials: credentials, configuration: configuration, apiClient: apiClient)
        operation.uploadCompletion = completion
        queue.addOperation(operation)
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
}
