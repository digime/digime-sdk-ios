//
//  FileUploadService.swift
//  DigiMeSDK
//
//  Created on 08/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

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
    
    func uploadFilePostbox(data: Data, metadata: Data, credentials: Credentials, completion: @escaping (Result<Session, SDKError>) -> Void) {
        let operation = FileUploadOperation(data: data, metadata: metadata, credentials: credentials, configuration: configuration, apiClient: apiClient)
        operation.uploadCompletion = completion
        queue.addOperation(operation)
    }
	
	func uploadFileDirect(data: Data, metadata: RawFileMetadata, credentials: Credentials, completion: @escaping (Result<Void, SDKError>) -> Void) {
		let operation = FileUploadUnencryptedOperation(data: data, metadata: metadata, credentials: credentials, configuration: configuration, apiClient: apiClient)
		operation.uploadCompletion = completion
		queue.addOperation(operation)
	}
    
    func uploadLog(logName: String, metadata: LogEventMeta, completion: @escaping (Result<LogEventsUploadResponse, SDKError>) -> Void) {
		guard let jwt = JWTUtility.logsUploadRequestJWT(configuration: configuration) else {
			Logger.critical("Invalid MAF mixpanel log upload request JWT")
			completion(.failure(SDKError.invalidPreAuthorizationRequestJwt))
			return
		}
		
		let timestamp = Int(Date().timeIntervalSince1970)
		let agent = LogEventAgent(sdk: APIConfig.agent)
		let distinctId = UIDevice.current.identifierForVendor!.uuidString
		let hashedId = Crypto.md5Hash(from: distinctId)
		let event = LogEvent(event: logName, timestamp: timestamp, distinctId: hashedId, meta: metadata)
		let bodyPayload = LogEventPayload(agent: agent, events: [event])
		let operation = LogEventsUploadOperation(jwt: jwt, payload: bodyPayload, configuration: configuration, apiClient: apiClient)
        operation.uploadCompletion = completion
        queue.addOperation(operation)
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
}
