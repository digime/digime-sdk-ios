//
//  FileDownloadOperation.swift
//  DigiMeSDK
//
//  Created on 25/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class FileDownloadOperation: RetryingOperation {
    
    private let apiClient: APIClient
    private let dataDecryptor: DataDecryptor
    private let sessionKey: String
	private let credentials: Credentials
	private let configuration: Configuration
    private let fileId: String
    private let updatedDate: Date
    
    var downloadCompletion: ((Result<File, SDKError>) -> Void)?
    
	init(fileId: String, sessionKey: String, credentials: Credentials, configuration: Configuration, updatedDate: Date, apiClient: APIClient, dataDecryptor: DataDecryptor) {
		self.fileId = fileId
		self.sessionKey = sessionKey
		self.credentials = credentials
		self.configuration = configuration
		self.updatedDate = updatedDate
        self.apiClient = apiClient
        self.dataDecryptor = dataDecryptor
    }
    
    override func main() {
        guard !isCancelled else {
            finish()
            return
        }
		
		guard let jwt = JWTUtility.fileDownloadRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
			downloadCompletion?(.failure(.errorCreatingRequestJwtToDownloadFile))
			return
		}
		
		let route = ReadDataRoute(jwt: jwt, sessionKey: sessionKey, fileId: fileId)
        apiClient.makeRequest(route) { result in
            let newResult: Result<File, SDKError>?
            do {
                let response = try result.get()
				guard !response.data.isEmpty else {
					Logger.info("Download file response has empty data.")
					self.retry()
					newResult = nil
					return
				}

				let unpackedData = try self.dataDecryptor.decrypt(response: response, dataIsHashed: false)
                let file = File(fileWithId: self.fileId, rawData: unpackedData, metadata: response.info.metadata, updated: self.updatedDate)
                newResult = .success(file)
            }
            catch SDKError.httpResponseError(404, _) where self.canRetry {
                    Logger.info("Queue a retry, so don't finish or call download handler")
                    self.retry()
                    newResult = nil
            }
			catch let sdkError as SDKError {
				newResult = .failure(sdkError)
			}
            catch {
				newResult = .failure(.fileDownloadOperationError(error: error))
            }
            
            if let newResult = newResult {
                self.downloadCompletion?(newResult)
                self.finish()
            }
        }
    }
    
    override func cancel() {
        downloadCompletion = nil
        super.cancel()
    }
}
