//
//  StorageUploadService.swift
//  DigiMeSDK
//
//  Created on 30/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation
import UIKit

class StorageUploadService {
    private let queue: OperationQueue
    private let storageClient: StorageClient
    private let configuration: Configuration

    init(storageClient: StorageClient, configuration: Configuration) {
        self.storageClient = storageClient
        self.configuration = configuration

        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "me.digi.sdk.storageuploadservice"
    }

    func upload(storageId: String, fileName: String, data: Data, path: String? = nil, completion: @escaping (Result<StorageUploadFileInfo, SDKError>) -> Void) {
        let operation = StorageUploadOperation(storageId: storageId, fileName: fileName, data: data, configuration: configuration, storageClient: storageClient, path: path)
        operation.uploadCompletion = completion
        queue.addOperation(operation)
    }

    func cancel() {
        queue.cancelAllOperations()
    }
}
