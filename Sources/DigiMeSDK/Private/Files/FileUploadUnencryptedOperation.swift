//
//  FileUploadUnencryptedOperation.swift
//  DigiMeSDK
//
//  Created on 25/08/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class FileUploadUnencryptedOperation: RetryingOperation {
	
	private let apiClient: APIClient
	private let data: Data
	private let metadata: RawFileMetadata
	private let credentials: Credentials
	private let configuration: Configuration
	
	var uploadCompletion: ((Result<Void, SDKError>) -> Void)?
	
	init(data: Data, metadata: RawFileMetadata, credentials: Credentials, configuration: Configuration, apiClient: APIClient) {
		self.apiClient = apiClient
		self.data = data
		self.metadata = metadata
		self.credentials = credentials
		self.configuration = configuration
	}
		
	override func main() {
		guard !isCancelled else {
			finish()
			return
		}

		do {
			guard
				let jwt = JWTUtility.fileUploadRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration),
				let fileDescriptor = JWTUtility.fileDescriptorUploadRequestJWT(metadata: metadata, configuration: configuration) else {
				
				throw SDKError.writeRequestFailure
			}
			
			let route = UploadDataDirectRoute(payload: data, jwt: jwt, fileDescriptor: fileDescriptor)
			apiClient.makeRequestFileUpload(route, uploadData: data) { result in
				self.uploadCompletion?(result)
				self.finish()
			}
		}
		catch {
			uploadCompletion?(.failure(.writeRequestFailure))
			finish()
		}
	}
	
	override func cancel() {
		uploadCompletion = nil
		super.cancel()
	}
}
