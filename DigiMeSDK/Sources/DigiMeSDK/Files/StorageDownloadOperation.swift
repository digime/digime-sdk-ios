//
//  StorageDownloadOperation.swift
//  DigiMeSDK
//
//  Created on 30/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

class StorageDownloadOperation: RetryingOperation, @unchecked Sendable {
    private let storageClient: StorageClient
    private let dataDecryptor: DataDecryptor
    private let configuration: Configuration
    private let storageId: String
    private let fileName: String
    private var filePath: String?

    var downloadCompletion: ((Result<Data, SDKError>) -> Void)?

    init(storageId: String, fileName: String, configuration: Configuration, storageClient: StorageClient, dataDecryptor: DataDecryptor, filePath: String? = nil) {
        self.fileName = fileName
        self.storageId = storageId
        self.configuration = configuration
        self.storageClient = storageClient
        self.dataDecryptor = dataDecryptor
        self.filePath = filePath
    }

    override func main() {
        guard !isCancelled else {
            finish()
            return
        }

        guard let jwt = JWTUtility.createCloudJWT(configuration: configuration) else {
            downloadCompletion?(.failure(.errorCreatingDataRequestJwt))
            return
        }

        let route = StorageFileRoute(jwt: jwt, storageId: storageId, applicationId: configuration.appId, fileName: fileName, formatedPath: filePath)
        storageClient.makeRequest(route) { result in
            let newResult: Result<Data, SDKError>?
            do {
                let response = try result.get()
                guard !response.isEmpty else {
                    Logger.info("Download storage file response has empty data.")
                    self.retry()
                    newResult = nil
                    return
                }

                let unpackedData = try self.dataDecryptor.decrypt(storageData: response)
                newResult = .success(unpackedData)
            }
            catch SDKError.httpResponseError(404, _) where self.canRetry {
                Logger.info("Queue a retry, so don't finish or call storage download handler")
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
