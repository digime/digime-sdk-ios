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
                NSLog("[FileService] Queue downloads complete")
                self.allDownloadsFinishedHandler?()
            }
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
    
    func downloadFile(sessionKey: String, fileId: String, completion: @escaping (Result<FileContainer<RawData>, Error>) -> Void) {
        let operation = FileDownloadOperation(sessionKey: sessionKey, fileId: fileId, apiClient: apiClient, dataDecryptor: dataDecryptor)
        operation.downloadCompletion = completion
        queue.addOperation(operation)
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
}

class FileDownloadOperation: RetryingOperation {
    
    private let apiClient: APIClient
    private let dataDecryptor: DataDecryptor
    private let sessionKey: String
    private let fileId: String
    
    var downloadCompletion: ((Result<FileContainer<RawData>, Error>) -> Void)?
    
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
            let newResult: Result<FileContainer<RawData>, Error>?
            do {
                let (data, fileInfo) = try result.get()
                var unpackedData = try self.dataDecryptor.decrypt(fileContent: data)
                if fileInfo.compression == "gzip" {
                    unpackedData = try DataCompressor.gzip.decompress(data: unpackedData)
                }
                
                let file = try FileContainer(fileWithId: self.fileId, rawData: unpackedData, mimeType: .applicationOctetStream, dataType: RawData.self)
                file.metadata = fileInfo.metadata
                newResult = .success(file)
            }
            catch let error as HTTPError {
                switch error {
                case let .unsuccesfulStatusCode(404, _) where self.canRetry:
                    // Queue a retry, so don't finish or call download handler
                    self.retry()
                    newResult = nil
                default:
                    newResult = .failure(error)
                }
            }
            catch {
                newResult = .failure(error)
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
