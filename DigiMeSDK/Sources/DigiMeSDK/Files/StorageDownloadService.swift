//
//  StorageDownloadService.swift
//  DigiMeSDK
//
//  Created on 30/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

class StorageDownloadService {
    private let queue: OperationQueue
    private let storageClient: StorageClient
    private let dataDecryptor: DataDecryptor

    private var kvoToken: NSKeyValueObservation?

    var allDownloadsFinishedHandler: (() -> Void)?

    var isDownloadingFiles: Bool {
        queue.operationCount > 0 && !queue.isSuspended
    }

    init(storageClient: StorageClient, dataDecryptor: DataDecryptor) {
        self.storageClient = storageClient
        self.dataDecryptor = dataDecryptor

        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.name = "me.digi.sdk.storagedownloadservice"

        kvoToken = queue.observe(\.operationCount, options: .new) { _, change in
            if change.newValue == 0 {
                self.allDownloadsFinishedHandler?()
            }
        }
    }

    deinit {
        kvoToken?.invalidate()
    }

    func downloadFile(storageId: String, fileName: String, configuration: Configuration, filePath: String? = nil, completion: @escaping (Result<Data, SDKError>) -> Void) {
        let operation = StorageDownloadOperation(storageId: storageId, fileName: fileName, configuration: configuration, storageClient: storageClient, dataDecryptor: dataDecryptor, filePath: filePath)
        operation.downloadCompletion = completion
        queue.addOperation(operation)
    }

    func cancel() {
        queue.cancelAllOperations()
    }
}

