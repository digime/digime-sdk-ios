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
    private let fileId: String
    
    var downloadCompletion: ((Result<File, SDKError>) -> Void)?
    
    init(sessionKey: String, fileId: String, apiClient: APIClient, dataDecryptor: DataDecryptor) {
        self.apiClient = apiClient
        self.dataDecryptor = dataDecryptor
        self.sessionKey = sessionKey
        self.fileId = fileId
    }
    
    override func main() {
        guard !isCancelled else {
            finish()
            return
        }
        
        let route = ReadDataRoute(sessionKey: sessionKey, fileId: fileId)
        apiClient.makeRequest(route) { result in
            let newResult: Result<File, SDKError>?
            do {
                let response = try result.get()
                let unpackedData = try self.dataDecryptor.decrypt(response: response)
                let file = File(fileWithId: self.fileId, rawData: unpackedData, metadata: response.info.metadata)
                newResult = .success(file)
            }
            catch SDKError.httpResponseError(404, _) where self.canRetry {
                    // Queue a retry, so don't finish or call download handler
                    self.retry()
                    newResult = nil
            }
            catch {
                newResult = .failure(.other)
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
