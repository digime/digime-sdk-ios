//
//  LogEventsUploadOperation.swift
//  DigiMeSDK
//
//  Created on 11/08/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

class LogEventsUploadOperation: RetryingOperation {
	private let apiClient: APIClient
	private let jwt: String
	private let payload: LogEventPayload
	private let configuration: Configuration
	
	var uploadCompletion: ((Result<LogEventsUploadResponse, SDKError>) -> Void)?
	
	init(jwt: String, payload: LogEventPayload, configuration: Configuration, apiClient: APIClient) {
		self.apiClient = apiClient
		self.jwt = jwt
		self.payload = payload
		self.configuration = configuration
	}
		
	override func main() {
		guard !isCancelled else {
			finish()
			return
		}
		
		guard
			let body = try? JSONRequestBody(parameters: payload) else {
			
			uploadCompletion?(.failure(.healthDataUnableToUploadLogEvent))
			finish()
			return
		}

		apiClient.makeRequest(UploadMixpanelEventsRoute(body: body, jwt: jwt)) { result in
			switch result {
			case .failure(let error):
				Logger.error(error.description)
			default:
				break
			}
			self.uploadCompletion?(result)
			self.finish()
		}
	}
	
	override func cancel() {
		uploadCompletion = nil
		super.cancel()
	}
}
