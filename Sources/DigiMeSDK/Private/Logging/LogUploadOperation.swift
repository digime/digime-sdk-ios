//
//  LogUploadOperation.swift
//  DigiMeSDK
//
//  Created on 05/08/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

class LogUploadOperation: RetryingOperation {
    
    private let logName: String
    private let metadata: [String: String]
    private let configuration: Configuration
    private let apiClient: APIClient
    
    var uploadCompletion: ((Result<LoggingResponse, SDKError>) -> Void)?
    
    init(logName: String, metadata: [String: String], configuration: Configuration, apiClient: APIClient) {
        self.logName = logName
        self.metadata = metadata
        self.configuration = configuration
        self.apiClient = apiClient
    }
    
    override func main() {
        guard !isCancelled else {
            finish()
            return
        }
        
        let route = LoggingRoute(appId: configuration.appId, contractId: configuration.contractId, schemaVersion: "5.0.0")
        apiClient.makeRequest(route) { result in
            self.uploadCompletion?(result)
            self.finish()
        }
    }
    
    override func cancel() {
        uploadCompletion = nil
        super.cancel()
    }
}
