//
//  FileService.swift
//  DigiMeSDK
//
//  Created on 25/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class FileService {
    private let queue: OperationQueue
    private let apiClient: APIClient
    private let dataDecryptor: DataDecryptor
    
    private var kvoToken: NSKeyValueObservation?
    
    var allDownloadsFinishedHandler: (() -> Void)?
    
    var isDownloadingFiles: Bool {
        queue.operationCount > 0 && !queue.isSuspended
    }
    
    init(apiClient: APIClient, dataDecryptor: DataDecryptor) {
        self.apiClient = apiClient
        self.dataDecryptor = dataDecryptor
        
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.name = "me.digi.sdk.fileservice"
        
        kvoToken = queue.observe(\.operationCount, options: .new) { _, change in
            if change.newValue == 0 {
                self.allDownloadsFinishedHandler?()
            }
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
    
    func downloadFile(sessionKey: String, fileId: String, completion: @escaping (Result<File, SDKError>) -> Void) {
        let operation = FileDownloadOperation(sessionKey: sessionKey, fileId: fileId, apiClient: apiClient, dataDecryptor: dataDecryptor)
        operation.downloadCompletion = completion
        queue.addOperation(operation)
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
}
