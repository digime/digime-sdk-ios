//
//  DigiMeSDK.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// The entry point to the SDK
public class DigiMeSDK {
    
    private let configuration: Configuration
    
    private let authService: OAuthService
    private let consentManager: ConsentManager
    private let credentialCache: CredentialCache
    private let sessionCache: SessionCache
    private let apiClient: APIClient
    private let dataDecryptor: DataDecryptor
    
    private lazy var fileService: FileService = {
        FileService(apiClient: apiClient, dataDecryptor: dataDecryptor)
    }()
    
    private var sessionDataCompletion: ((Result<FileList, Error>) -> Void)?
    private var sessionContentHandler: ((Result<FileContainer<RawData>, Error>) -> Void)?
    
    /*@Atomic*/ private var isFetchingSessionData = false
    private var fileListCache = FileListCache()
    private var sessionError: Error?
    private var sessionFileList: FileList?
    private var stalePollCount = 0
    
    private let maxStalePolls = 100
    private let pollInterval = 3
    
    private var isSyncRunning: Bool {
        // If no session file list, could be because we haven't received response yet, so assume is running
        return sessionFileList?.status.state.isRunning ?? true
    }
    
    /// Initialises a new instance of SDK.
    /// A new instance should be created for each contract the app uses
    /// - Parameter configuration: The configuration which defines this instance
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.credentialCache = CredentialCache()
        self.apiClient = APIClient(credentialCache: credentialCache)
        self.authService = OAuthService(configuration: configuration, apiClient: apiClient)
        self.consentManager = ConsentManager(configuration: configuration)
        self.sessionCache = SessionCache()
        self.dataDecryptor = DataDecryptor(configuration: configuration)
        
//        credentialCache.setCredentials(nil, for: configuration.contractId)
    }
    
    /// Authorizes user and creates a session during which user can retrieve data from added sources
    ///
    /// If the user has not already authorized, will present a view controller in which user consents and optionally chooses a source to add.
    ///
    /// If user has already authorized, refreshes the session, if necessary.
    ///
    /// - Parameters:
    ///   - readOptions: Options to filter which data is read from sources
    ///   - completion: Block called upon authorization compeltion with any errors encountered.
    public func authorize(readOptions: ReadOptions?, completion: @escaping (Error?) -> Void) {
        if let validationError = validateClient() {
            return completion(validationError)
        }
        
        validateOrRefreshCredentials { result in
            switch result {
            case .success(let credentials):
                completion(nil)
//                self.refreshSession(credentials: credentials, readOptions: readOptions, completion: completion)
                
            case .failure(SDKError.authenticationRequired):
                self.beginAuth(readOptions: readOptions, completion: completion)
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    public func readAccounts(completion: @escaping (Result<AccountsInfo, Error>) -> Void) {
        let credentials = credentialCache.credentials(for: configuration.contractId)!
        refreshSession(credentials: credentials, readOptions: nil) { result in
            do {
                let session = try result.get()
                self.apiClient.makeRequest(ReadDataRoute(sessionKey: session.key, fileId: "accounts.json")) { result in
                    do {
                        let (data, fileInfo) = try result.get()
                        var unpackedData = try self.dataDecryptor.decrypt(fileContent: data)
                        if fileInfo.compression == "gzip" {
                            unpackedData = try DataCompressor.gzip.decompress(data: unpackedData)
                        }
                    
                        let accounts = try unpackedData.decoded() as AccountsInfo
                        completion(.success(accounts))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    public func readFiles(downloadHandler: @escaping (Result<FileContainer<RawData>, Error>) -> Void, completion: @escaping (Result<FileList, Error>) -> Void) {
        let credentials = credentialCache.credentials(for: configuration.contractId)!
        refreshSession(credentials: credentials, readOptions: nil) { result in
            do {
                let session = try result.get()
                
                self.sessionDataCompletion = completion
                self.sessionContentHandler = downloadHandler
                
                self.beginFileListPollingIfRequired()
                
//                self.apiClient.makeRequest(ReadDataRoute(sessionKey: session.key, fileId: "accounts.json")) { result in
//                    do {
//                        let (data, fileInfo) = try result.get()
//                        var unpackedData = try self.dataDecryptor.decrypt(fileContent: data)
//                        if fileInfo.compression == "gzip" {
//                            unpackedData = try DataCompressor.gzip.decompress(data: unpackedData)
//                        }
//
//                        let fileList = try unpackedData.decoded() as FileList
//                        completion(.success(fileList))
//                    }
//                    catch {
//                        completion(.failure(error))
//                    }
//                }
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    public func write(data: Data, metadata: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        validateOrRefreshCredentials { result in
            switch result {
            case .success(let credentials):
                self.write(data: data, metadata: metadata, credentials: credentials, completion: completion)
            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func write(data: Data, metadata: Data, credentials: Credentials, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let writeAccessInfo = credentials.writeAccessInfo else {
            return// completion(.failure(T##Error)) // What error should we return?
        }
        
        let symmetricKey = AES256.generateSymmetricKey()
        let iv = AES256.generateInitializationVector()
        
        do {
            let aes = try AES256(key: symmetricKey, iv: iv)
            
            let encryptedMetadata = try aes.encrypt(metadata).base64EncodedString(options: .lineLength64Characters)
            let payload = try aes.encrypt(data)
            let encryptedSymmetricKey = try Crypto.encrypt(symmetricKey: symmetricKey, publicKey: writeAccessInfo.publicKey)
            guard let jwt = JWTUtility.writeRequestJWT(accessToken: credentials.token.accessToken.value, iv: iv, metadata: encryptedMetadata, symmetricKey: encryptedSymmetricKey, configuration: self.configuration) else {
                return //completion(.failure(<#T##Error#>)) // What error should we return?
            }
            
            self.apiClient.makeRequest(WriteDataRoute(postboxId: writeAccessInfo.postboxId, payload: payload, jwt: jwt)) { result in
                if let response = try? result.get() {
                    self.sessionCache.contents = response.session
                }
                
                completion(result.map { _ in Void() })
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    // Auth - needs app to be able to receive response via URL
    private func beginAuth(readOptions: ReadOptions?, completion: @escaping (Error?) -> Void) {
        authService.requestPreAuthorizationCode(readOptions: nil) { result in
            if let response = try? result.get() {
                self.sessionCache.contents = response.session
                self.performAuth(preAuthResponse: response, serviceId: 2) { result in
                    switch result {
                    case .success:
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
        }
    }
    
    // Refresh read session by triggering source sync
    private func refreshSession(credentials: Credentials, readOptions: ReadOptions?, completion: @escaping (Result<Session, Error>) -> Void) {
        if let session = sessionCache.contents,
           session.isValid {
            return completion(.success(session))
        }
        
        guard let jwt = JWTUtility.dataTriggerRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
            return //completion(.failure(<#T##Error#>)) // What error should we return?
        }
        
        apiClient.makeRequest(TriggerSyncRoute(jwt: jwt, agent: nil, readOptions: readOptions)) { result in
            do {
                let response = try result.get()
                self.sessionCache.contents = response.session
                completion(.success(response.session))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    private func validateOrRefreshCredentials(completion: @escaping (Result<Credentials, Error>) -> Void) {
        // Check we have credentials
        guard let credentials = credentialCache.credentials(for: configuration.contractId) else {
            return completion(.failure(SDKError.authenticationRequired))
        }
        
        guard credentials.token.accessToken.isValid else {
            return refreshTokens(credentials: credentials, completion: completion)
        }
        
        completion(.success(credentials))
    }
    
    private func refreshTokens(credentials: Credentials, completion: @escaping (Result<Credentials, Error>) -> Void) {
        guard credentials.token.refreshToken.isValid else {
            return reauthorize(accessToken: credentials.token.accessToken, completion: completion)
        }
        
        authService.renewAccessToken(oauthToken: credentials.token) { result in
            do {
                let response = try result.get()
                let newCredentials = Credentials(token: response, writeAccessInfo: credentials.writeAccessInfo)
                self.credentialCache.setCredentials(newCredentials, for: self.configuration.contractId)
                print(response)
                completion(.success(newCredentials))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    private func reauthorize(accessToken: OAuthToken.Token, completion: @escaping (Result<Credentials, Error>) -> Void) {
        authService.requestPreAuthorizationCode(readOptions: nil, accessToken: accessToken.value) { result in
            do {
                let response = try result.get()
                self.sessionCache.contents = response.session
                self.performAuth(preAuthResponse: response, serviceId: nil, completion: completion)
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    private func performAuth(preAuthResponse: PreAuthResponse, serviceId: Int?, completion: @escaping (Result<Credentials, Error>) -> Void) {
        consentManager.requestUserConsent(preAuthCode: preAuthResponse.token, serviceId: serviceId) { result in
            do {
                let response = try result.get()
                self.exchangeToken(authResponse: response, completion: completion)
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    private func exchangeToken(authResponse: ConsentResponse, completion: @escaping (Result<Credentials, Error>) -> Void) {
        authService.requestTokenExchange(authCode: authResponse.authorizationCode) { result in
            do {
                let response = try result.get()
                let credentials = Credentials(token: response, writeAccessInfo: authResponse.writeAccessInfo)
                self.credentialCache.setCredentials(credentials, for: self.configuration.contractId)
                print(response)
                completion(.success(credentials))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    private func validateClient() -> Error? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return SDKError.noUrlScheme
        }
        
        let urlSchemes = urlTypes.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 }
        if !urlSchemes.contains("digime-ca-\(configuration.appId)") {
            return SDKError.noUrlScheme
        }
        
        return nil
    }
    
    // MARK: - File Contents
    private func beginFileListPollingIfRequired() {
        guard !isFetchingSessionData else {
            return
        }
        
        fileListCache.reset()
        isFetchingSessionData = true
        fileService.allDownloadsFinishedHandler = {
            NSLog("DigiMeSDK: Finished downloading all files")
            self.evaluateSessionDataFetchProgress(schedulePoll: false)
        }
        refreshFileList()
        scheduleNextPoll()
    }
    
    private func refreshFileList() {
        readFileList { result in
            switch result {
            case .success(let fileList):
                let fileListDidChange = fileList != self.sessionFileList
                self.stalePollCount += fileListDidChange ? 0 : 1
                guard self.stalePollCount < self.maxStalePolls else {
                    self.sessionError = SDKError.fileListPollingTimeout
                    return
                }
                
                // If subsequent fetch clears the error (stale one or otherwise) - great, no need to report it back up the chain
                self.sessionError = nil
                self.sessionFileList = fileList
                let newItems = self.fileListCache.newItems(from: fileList.files)
                let allFiles = newItems.map { $0.name }
                
                self.handleNewFileListItems(newItems)

            case .failure(let error):
            // If the error occurred we don't want to terminate right away
            // There could still be files downloading. Instead, we will store the sessionError
            // which will be forwarded in completion once all file have been downloaded
            
            // If no files are being downloaded, we can terminate session fetch right away
                if !self.fileService.isDownloadingFiles {
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
        
        NSLog("DigiMeSDK: Found new files to sync: \(items.count)")
        fileListCache.add(items: items)
        
        // If contentHandler is not provided, no need to download
        guard let sessionContentHandler = sessionContentHandler else {
            return
        }
        let credentials = credentialCache.credentials(for: configuration.contractId)!
        refreshSession(credentials: credentials, readOptions: nil) { result in
            do {
                let session = try result.get()
                items.forEach { item in
                    NSLog("DigiMeSDK: Adding file to download queue: \(item.name)")
                    self.fileService.downloadFile(sessionKey: session.key, fileId: item.name, completion: sessionContentHandler)
                }
            }
            catch {
                self.sessionError = error
            }
        }
    }
    
    private func readFileList(completion: @escaping (Result<FileList, Error>) -> Void) {
        let credentials = credentialCache.credentials(for: configuration.contractId)!
        refreshSession(credentials: credentials, readOptions: nil) { result in
            do {
                let session = try result.get()
                self.apiClient.makeRequest(FileListRoute(sessionKey: session.key), completion: completion)
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    private func scheduleNextPoll() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(pollInterval)) { [weak self] in
            self?.evaluateSessionDataFetchProgress(schedulePoll: true)
        }
    }
    
    private func completeSessionDataFetch(error: Error?) {
        sessionDataCompletion?(error != nil ? .failure(error!) : .success(sessionFileList!))
        clearSessionData()
    }
    
    private func clearSessionData() {
        isFetchingSessionData = false
        
        fileListCache.reset()
        sessionFileList = nil
        sessionDataCompletion = nil
        sessionContentHandler = nil
        fileService.allDownloadsFinishedHandler = nil
//        fileService = nil
        sessionError = nil
        stalePollCount = 0
    }
    
    private func evaluateSessionDataFetchProgress(schedulePoll: Bool) {
        guard isFetchingSessionData else {
            return
        }
        
        NSLog("DigiMeSDK: Sync state - \(sessionFileList != nil ? sessionFileList!.status.state.rawValue : "unknown")")
        
        // If sessionError is not nil, then syncState is irrelevant, as it will be the previous successful fileList call.
        if (sessionError != nil || !isSyncRunning) && !self.fileService.isDownloadingFiles {
            NSLog("DigiMeSDK: Finished fetching session data.")
            
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

class FileListCache {
    
    private var cache = [String: Date]()
//    var allItems: [FileListItem] {
//        cache.map { FileListItem(name: $0, updateDate: $1) }
//    }
//
    func newItems(from items: [FileListItem]) -> [FileListItem] {
        items.filter { item in
            guard let existingItem = cache[item.name] else {
                return true
            }

            return existingItem < item.updatedDate
        }
    }

    func add(items: [FileListItem]) {
        items.forEach { cache[$0.name] = $0.updatedDate }
    }
    
    func reset() {
        cache = [:]
    }
}
