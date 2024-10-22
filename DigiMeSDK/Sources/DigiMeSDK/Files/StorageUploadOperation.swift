//
//  StorageUploadOperation.swift
//  DigiMeSDK
//
//  Created on 30/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

class StorageUploadOperation: RetryingOperation, @unchecked Sendable {
    private let data: Data
    private let configuration: Configuration
    private let storageClient: StorageClient
    private let storageId: String
    private let fileName: String
    private var filePath: String?
    
    var uploadCompletion: ((Result<StorageUploadFileInfo, SDKError>) -> Void)?

    init(storageId: String, fileName: String, data: Data, configuration: Configuration, storageClient: StorageClient, path: String? = nil) {
        self.storageId = storageId
        self.fileName = fileName
        self.data = data
        self.configuration = configuration
        self.storageClient = storageClient
        self.filePath = path
    }

    override func main() {
        guard !isCancelled else {
            finish()
            return
        }

        do {
            guard 
                let payload = try? Crypto.encrypt(inputData: data, privateKeyData: configuration.privateKeyData),
                let jwt = JWTUtility.createCloudJWT(configuration: configuration) else {
                throw SDKError.writeRequestFailure
            }

            let route = StorageUploadFileRoute(jwt: jwt, storageId: storageId, applicationId: configuration.appId, fileName: fileName, formatedPath: filePath)
            storageClient.makeRequestFileUpload(route, uploadData: payload) { result in
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
