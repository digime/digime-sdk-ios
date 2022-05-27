//
//  AllFilesReader.swift
//  DigiMeSDK
//
//  Created on 13/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class AllFilesReader {
    
    private let sessionCache = SessionCache()
    @Atomic private var isFetchingSessionData = false
    private var fileListCache = FileListCache()
    private var sessionError: SDKError?
    private var sessionFileList: FileList?
    private var stalePollCount = 0
    
    private let apiClient: APIClient
    private let configuration: Configuration
    
    private var sessionDataCompletion: ((Result<FileList, SDKError>) -> Void)?
    private var sessionContentHandler: ((Result<File, SDKError>) -> Void)?
    
    private lazy var downloadService: FileDownloadService = {
        FileDownloadService(apiClient: apiClient, dataDecryptor: DataDecryptor(configuration: configuration))
    }()
    
    private enum Defaults {
        static let maxStalePolls = 100
        static let pollInterval = 3
    }
    
    init(apiClient: APIClient, configuration: Configuration) {
        self.apiClient = apiClient
        self.configuration = configuration
    }
    
    private var session: Session? {
        get {
            sessionCache.session(for: configuration.contractId)
        }
        set {
            sessionCache.setSession(newValue, for: configuration.contractId)
        }
    }
    
    private var isSyncRunning: Bool {
        // If no session file list, could be because we haven't received response yet, so assume is running
        return sessionFileList?.status.state.isRunning ?? true
    }
    
    func readAllFiles(downloadHandler: @escaping (Result<File, SDKError>) -> Void, completion: @escaping (Result<FileList, SDKError>) -> Void) {
        guard !isFetchingSessionData else {
            completion(.failure(SDKError.alreadyReadingAllFiles))
            return
        }
        
        self.sessionDataCompletion = completion
        self.sessionContentHandler = downloadHandler
        
        self.beginFileListPollingIfRequired()
    }
	
	func clearSessionData() {
		isFetchingSessionData = false
		
		fileListCache.reset()
		sessionDataCompletion = nil
		sessionContentHandler = nil
		downloadService.cancel()
		downloadService.allDownloadsFinishedHandler = nil
		sessionError = nil
		stalePollCount = 0
	}
    
    private func beginFileListPollingIfRequired() {
        isFetchingSessionData = true
        downloadService.allDownloadsFinishedHandler = {
            Logger.info("Finished downloading all files")
            self.evaluateSessionDataFetchProgress(schedulePoll: false)
        }
        refreshFileList()
        scheduleNextPoll()
    }
    
    private func refreshFileList() {
        guard
            let session = session,
            session.isValid else {
            
            // Cannot continue without valid session
            return completeSessionDataFetch(error: .invalidSession)
        }
        
        apiClient.makeRequest(FileListRoute(sessionKey: session.key)) { result in
            switch result {
            case .success(let fileList):
                let fileListDidChange = fileList != self.sessionFileList
                self.stalePollCount += fileListDidChange ? 0 : 1
                guard self.stalePollCount < Defaults.maxStalePolls else {
                    self.sessionError = SDKError.fileListPollingTimeout
                    return
                }
                
                // If subsequent fetch clears the error (stale one or otherwise) - great, no need to report it back up the chain
                self.sessionError = nil
                self.sessionFileList = fileList
                let newItems = self.fileListCache.newItems(from: fileList.files ?? [])
                
                self.handleNewFileListItems(newItems)

            case .failure(let error):
                // If the error occurred we don't want to terminate right away
                // There could still be files downloading. Instead, we will store the sessionError
                // which will be forwarded in completion once all file have been downloaded
                
                // If no files are being downloaded, we can terminate session fetch right away
                if !self.downloadService.isDownloadingFiles {
                    self.completeSessionDataFetch(error: error)
                }
                
                self.sessionError = error
            }
        }
    }
    
    private func handleNewFileListItems(_ items: [FileListItem]) {
        guard !items.isEmpty else {
            return
        }
        
        Logger.debug("Found new files to sync: \(items.count)")
        fileListCache.add(items: items)
        
        // If contentHandler is not provided, no need to download
        guard let sessionContentHandler = sessionContentHandler else {
            return
        }
        
        guard
            let session = session,
            session.isValid else {
            
            // Cannot continue without valid session
            return completeSessionDataFetch(error: .invalidSession)
        }
        
        items.forEach { item in
            Logger.debug("Adding file to download queue: \(item.name)")
            self.downloadService.downloadFile(sessionKey: session.key, fileId: item.name, updatedDate: item.updatedDate, completion: sessionContentHandler)
        }
    }
    
    private func scheduleNextPoll() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Defaults.pollInterval)) { [weak self] in
            self?.evaluateSessionDataFetchProgress(schedulePoll: true)
        }
    }
    
    private func completeSessionDataFetch(error: SDKError?) {
        sessionDataCompletion?(error != nil ? .failure(error!) : .success(sessionFileList!))
        clearSessionData()
    }
    
    private func evaluateSessionDataFetchProgress(schedulePoll: Bool) {
        guard isFetchingSessionData else {
            return
        }
        
        Logger.debug("Sync state - \(sessionFileList != nil ? sessionFileList!.status.state.rawValue : "unknown")")
        
        // If sessionError is not nil, then syncState is irrelevant, as it will be the previous successful fileList call.
        if (sessionError != nil || !isSyncRunning) && !self.downloadService.isDownloadingFiles {
            Logger.info("Finished fetching session data.")
            
            completeSessionDataFetch(error: sessionError)
            return
        }
        else if schedulePoll {
            scheduleNextPoll()
        }
        
        // Not checking sessionError here on purpose. If we are here, then there are files still being downloaded
        // so we may as well poll the file list again, just in case the error clears.
        if isSyncRunning {
            refreshFileList()
        }
    }
}
