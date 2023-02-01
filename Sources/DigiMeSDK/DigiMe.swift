//
//  DigiMe.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import HealthKit

/// The entry point to the SDK
public final class DigiMe {
    
    public var isDownloadingFiles: Bool {
        return self.downloadService.isDownloadingFiles
    }

    private let configuration: Configuration
	private let authService: OAuthService
    private let consentManager: ConsentManager
    private let sessionCache: SessionCache
	private let contractsCache: ContractsCache
    private let apiClient: APIClient
    private let dataDecryptor: DataDecryptor
    private let certificateParser: CertificateParser
	private let healthSerivce: HealthKitService

    private lazy var downloadService: FileDownloadService = {
        FileDownloadService(apiClient: apiClient, dataDecryptor: dataDecryptor)
    }()
    
    private lazy var uploadService: FileUploadService = {
        FileUploadService(apiClient: apiClient, configuration: configuration)
    }()
    
    @Atomic private var allFilesReader: AllFilesReader?
    
    private var session: Session? {
        get {
            sessionCache.session(for: configuration.contractId)
        }
        set {
            sessionCache.setSession(newValue, for: configuration.contractId)
        }
    }
    
    /// The log levels for all `DigiMe` instances which will be included in logs.
    /// Defaults to `[.info, .warning, .error, .critical]`
    public class var logLevels: [LogLevel] {
        get {
            Logger.logLevels
        }
        set {
            Logger.logLevels = newValue
        }
    }
    
    /// Sets the custom log handler for all `DigiMe` instances to allow logging to a different system.
    /// DigiMeSDK uses `NSLog` by default.
    /// - Parameter handler: The log handler block
    public class func setLogHandler(_ handler: @escaping LogHandler) {
        Logger.setLogHandler(handler)
    }
    
    /// Initialises a new instance of SDK.
    /// A new instance should be created for each contract the app uses
    /// - Parameter configuration: The configuration which defines this instance
    public init(configuration: Configuration) {
        self.configuration = configuration
		self.apiClient = APIClient(with: configuration.baseUrl)
        self.authService = OAuthService(configuration: configuration, apiClient: apiClient)
        self.consentManager = ConsentManager(configuration: configuration)
        self.sessionCache = SessionCache()
		self.contractsCache = ContractsCache()
        self.dataDecryptor = DataDecryptor(configuration: configuration)
        self.certificateParser = CertificateParser()
		self.healthSerivce = HealthKitService()

        setupLogger()
    }
    
    /// Authorizes the contract configured with this digi.me instance to access to a library.
    ///
    /// Requires `CallbackService.shared().handleCallback(url:)` to be called from appropriate in `AppDelegate` or `SceneDelegate`place so that authorization can complete.
    ///
    /// If the user has not already authorized, will present a view controller in which user consents.
    /// If user has already authorized, refreshes the authorization, if necessary (which may require user consent again).
    ///
    /// To authorize this contract to access the same library that another contract has been authorized to access, specify the contract to link to's credentials. This is useful when a read contract needs to access the same library that a write contract has written deta to.
    ///
    /// Additionally for read contracts:
    /// - Upon first authorization, can optionally specify a service from which user can log in to and retrieve data.
    /// - Creates of refreshes a session during which data can be read from library.
    ///
    /// - Parameters:
    ///   - credentials: The existing credentials for the contract to authorize. If nil, will create credentials on success
    ///   - serviceId: Identifier of initial service to add. Only valid for first authorization of read contracts where user has not previously granted consent. Ignored for all subsequent calls.
    ///   - readOptions: Options to filter which data is read from sources for this session. Only used for read contracts.
    ///   - linkToContractWithCredentials: When specified, connects to same library as another contract.  Does nothing if user has already authorized this contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon authorization completion with new or refreshed credentials, or any errors encountered.
    public func authorize(credentials: Credentials? = nil, serviceId: Int? = nil, readOptions: ReadOptions? = nil, linkToContractWithCredentials linkCredentials: Credentials? = nil, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        if let validationError = validateClient() {
            resultQueue.async {
                completion(.failure(validationError))
            }
            return
        }
		
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                resultQueue.async {
                    completion(.success(refreshedCredentials))
                }
                
            case .failure(SDKError.authorizationRequired):
                self.beginAuth(serviceId: serviceId, readOptions: readOptions, linkToContractWithCredentials: linkCredentials) { authResult in
                    resultQueue.async {
                        completion(authResult)
                    }
                }
                
            case .failure(let error):
                resultQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Once a user has granted consent, adds an additional service. Also initiates synchronization of data from this service to user's library.
    ///
    /// - Parameters:
    ///   - identifier: Identifier of service to add.
    ///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with new or refreshed credentials, or any errors encountered
    public func addService(identifier: Int, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
            self.authService.requestReferenceToken(oauthToken: refreshedCredentials.token) { result in
                switch result {
                case .success(let response):
                    self.session = response.session
                    self.consentManager.addService(identifier: identifier, token: response.token) { result in
                        let mappedResult = result.map { refreshedCredentials }
                        resultQueue.async {
                            completion(mappedResult)
                        }
                    }
                
                case .failure(let error):
                    resultQueue.async {
                        completion(.failure(error))
                    }
                }
            }
                
            case .failure(let error):
                resultQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Reads the service data source accounts user has added to library related to the configured contract.
    ///
    /// Requires a valid session to have been created, either implicitly by adding a new service, or explicitly by calling `requestDataQuery(credentials:readOptions:resultQueue:completion)`.
    ///
    /// Note: If this is called on either a write-only contract or a contract which reads non-service data, this will return an error.
    ///
    /// - Parameters:
	///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion containing either relevant account info, if successful, or an error
    public func readAccounts(credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Result<AccountsInfo, SDKError>) -> Void) {
        guard
            let session = session,
            session.isValid else {
            return completion(.failure(.invalidSession))
        }
        
		readAccounts(session: session, credentials: credentials) { result in
            resultQueue.async {
                completion(result)
            }
        }
    }
    
    /// Fetches content for all the files limited by read options.
    ///
    /// An attempt is made to fetch each requested file and the result of the attempt is passed back via the download handler.
    /// As download requests are asynchronous, the download handler may be called concurrently, so the handler implementation should allow for this.
    ///
    /// If this function is called while files are being read, an error denoting this will be immediately
    /// returned in the completion block of this subsequent call and will not affect any current calls.
    ///
    /// For reading data written by another contract, it may be necessary for force a new session by calling `requestDataQuery(credentials:readOptions:resultQueue:completion)` first (and waiting for completion).
    ///
    /// For service-based data sources, will also attempt to retrieve any new data directly from the services, in which case this completion handler will not be called until this synchronization has finished.
    ///
    /// Alternatively, caller can manage reading files themselves by using the calls:
    /// `requestDataQuery()`, `readFileList()` and `readFile()`
    ///
    /// - Parameters:
    ///   - credentials: The existing credentials for the contract.
    ///   - readOptions: Options to filter which data is read from sources for this session. Only used for read contracts.
    ///   - resultQueue: The dispatch queue which the download handler and completion blocks will be called on. Defaults to main dispatch queue.
    ///   - downloadHandler: Handler called after every file fetch attempt finishes. Either contains the file or an error if fetch failed
    ///   - completion: Block called when fetching all files has completed. Contains final list of files (along with new or refreshed credentials) or an error if reading file list failed
    public func readAllFiles(credentials: Credentials, readOptions: ReadOptions?, resultQueue: DispatchQueue = .main, downloadHandler: @escaping (Result<File, SDKError>) -> Void, completion: @escaping (Result<(FileList, Credentials), SDKError>) -> Void) {
        guard allFilesReader == nil else {
            resultQueue.async {
                completion(.failure(SDKError.alreadyReadingAllFiles))
            }
            return
        }
        
		allFilesReader = AllFilesReader(apiClient: self.apiClient,
										credentials: credentials,
										healthSerivce: self.healthSerivce,
										certificateParser: self.certificateParser,
										contractsCache: self.contractsCache,
										configuration: self.configuration,
										readOptions: readOptions)
        
        allFilesReader?.readAllFiles(downloadHandler: { result in
            resultQueue.async {
                downloadHandler(result)
            }
        }, completion: { result in
            if case .failure(.invalidSession) = result {
                self.requestDataQuery(credentials: credentials, readOptions: readOptions, resultQueue: DispatchQueue.global()) { result in
                    switch result {
                    case .success(let refreshedCredentials):
                        self.allFilesReader?.readAllFiles(downloadHandler: { result in
                            resultQueue.async {
                                downloadHandler(result)
                            }
                        }, completion: { result in
                            self.allFilesReader = nil
                            resultQueue.async {
                                completion(result.map { ($0, refreshedCredentials) })
                            }
                        })
                        
                    case .failure(let error):
                        self.allFilesReader = nil
                        resultQueue.async {
                            completion(.failure(error))
                        }
                    }
                }
                
                return
            }
            
            self.allFilesReader = nil
            resultQueue.async {
                completion(result.map { ($0, credentials) })
            }
        })
    }
    
    /// Creates a session during which files can be read. This session is typically valid for 15 minutes.
    /// Once it has expired, a new session will be required to continue reading data.
    ///
    /// For service-based data sources, will also attempt to retrieve any new data directly from the services.
    ///
    /// - Parameters:
    ///   - credentials: The existing credentials for the contract.
    ///   - readOptions: Options to filter which data is read from sources for this session. Only used for read contracts.
    ///   - resultQueue: The dispatch queue which the download handler and completion blocks will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with new or refreshed credentials, or any errors encountered.
    public func requestDataQuery(credentials: Credentials, readOptions: ReadOptions?, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.triggerSourceSync(credentials: refreshedCredentials, readOptions: readOptions) { result in
                    resultQueue.async {
                        completion(result.map { refreshedCredentials })
                    }
                }
                
            case .failure(let error):
                resultQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Retrieves a list of files contained within the user's library.
    ///
    /// Requires a valid session to have been created, either implicitly by adding a new service, or explicitly by calling `requestDataQuery(credentials:readOptions:resultQueue:completion)`.
    ///
    /// For service-based sources, it can take a while for new data to be added to user's library (following a `requestDataQuery` call).
    /// Therefore caller should poll this call while data is being added to the library in case new files become available.
    /// Synchronization is complete when `fileList.status.state.isRunning` becomes `false`.
    ///
    /// - Parameters:
	///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the download handler and completion blocks will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with the list of files, or any errors encountered.
    public func readFileList(credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Result<FileList, SDKError>) -> Void) {
        guard
            let session = session,
            session.isValid else {
            return completion(.failure(.invalidSession))
        }
        
		guard let jwt = JWTUtility.fileDownloadRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
			return completion(.failure(.errorCreatingRequestJwtToDownloadFile))
		}
		
		let route = FileListRoute(jwt: jwt, sessionKey: session.key)
        apiClient.makeRequest(route) { result in
            resultQueue.async {
                completion(result)
            }
        }
    }
    
    /// Retrieves the content of a specified file.
    ///
    /// Requires a valid session to have been created, either implicitly by adding a new service, or explicitly by calling `requestDataQuery(credentials:readOptions:resultQueue:completion)`.
    ///
    /// - Parameters:
    ///   - fileId: The file's identifier.
	///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the download handler and completion blocks will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with file, or any errors encountered.
	public func readFile(fileId: String, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Result<File, SDKError>) -> Void) {
        guard
            let session = session,
            session.isValid else {
            return completion(.failure(.invalidSession))
        }
        
		downloadService.downloadFile(fileId: fileId, sessionKey: session.key, credentials: credentials, configuration: configuration) { result in
            resultQueue.async {
                completion(result)
            }
        }
    }
	
	/// Writes data directly to user's library associated with configured contract.
	/// - Parameters:
	///   - data: The data to be written
	///   - metadata: The metadata describing the data to be written. See `RawFileMetadataBuilder` for details on building the metadata
	///   - credentials: The existing credentials for the contract.
	///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
	///   - completion: Block called when writing data has complete with new or refreshed credentials, or any errors encountered.
	public func write(data: Data, metadata: RawFileMetadata, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
		validateOrRefreshCredentials(credentials) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.writeDirect(data: data, metadata: metadata, credentials: refreshedCredentials) { result in
					resultQueue.async {
						completion(result)
					}
				}
			
			case .failure(let error):
				resultQueue.async {
					completion(.failure(error))
				}
			}
		}
	}
    
    /// Deletes the user's library associated with the configured contract.
    ///
    /// Please note that if multiple contracts are linked to the same library,
    /// then `deleteUser` will also invalidate any credentials for those contracts.
    ///
    /// - Parameters:
    ///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called on completion with any error encountered.
    public func deleteUser(credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (SDKError?) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.authService.deleteUser(oauthToken: refreshedCredentials.token) { result in
                    self.session = nil
                    resultQueue.async {
                        switch result {
                        case .success:
                            completion(nil)
                        case .failure(let error):
                            completion(error)
                        }
                    }
                }
            
            case .failure(let error):
                resultQueue.async {
                    completion(error)
                }
            }
        }
    }
    
    /// Get a list of possible services a user can add to their digi.me.
    /// If contract identifier is specified, then only those services relevant to the contract are retrieved, otherwise all services are retrieved.
    ///
    /// - Parameters:
    ///   - contractId: The contract identifier for which relevant available services are retrieved. If `nil` then all services are retrieved.
    ///   - filterAvailable: Filter all services by: “approved” && “production” && “available”
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with either the service list or any errors encountered
    public func availableServices(contractId: String?, filterAvailable: Bool = true, resultQueue: DispatchQueue = .main, completion: @escaping (Result<ServicesInfo, SDKError>) -> Void) {
        let route = ServicesRoute(contractId: contractId)
        apiClient.makeRequest(route) { result in
            switch result {
            case .success(let response):
                var availableServices = response.data.services
                
                if filterAvailable {
                    availableServices = availableServices.filter { $0.isAvailable }
                }
                
                let info = ServicesInfo(countries: response.data.countries, serviceGroups: response.data.serviceGroups, services: availableServices)
                resultQueue.async {
                    completion(.success(info))
                }
                
            case .failure(let error):
                resultQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
	
	/// Clear cached data.
	///
	/// - Parameters:
	///   - contractId: The contract identifier for which relevant available service
	public func clearCachedData(for contractId: String) {
		allFilesReader?.clearSessionData()
		CredentialCache().clearCredentials(for: contractId)
		SessionCache().clearSession(for: contractId)
		ContractsCache().clearTimeRanges(for: contractId)
		LocalDataCache().deviceDataRequested = false
	}
    
    /// Get contract details.
    /// If contract identifier is specified, then only those services relevant to the contract are retrieved, otherwise all services are retrieved.
    ///
    /// - Parameters:
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with either the contract object or any errors encountered
    public func contractDetails(resultQueue: DispatchQueue = .main, completion: @escaping (Result<ContractVersion5, SDKError>) -> Void) {
        let appId = configuration.appId
        let contractId = configuration.contractId
            
        let route = ContractRoute(appId: appId, contractId: contractId, schemaVersion: "5.0.0")
        apiClient.makeRequest(route) { result in
            switch result {
            case .success(let response):
                resultQueue.async {
                    self.certificateParser.parse(contractResponse: response) { result in
                        completion(result)
                    }
                }
                
            case .failure(let error):
                resultQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Apple Health
    
	public func appleHealthStatisticsCollectionQuery(for contractId: String, queryConfig: HealthKitConfiguration, resultQueue: DispatchQueue = .main, accountHandler: @escaping (SourceAccount) -> Void, completion: @escaping (StatisticsCompletionHandler)) {
		
		accountHandler(HealthKitData().account)
		healthSerivce.requestAuthorization(typesToRead: queryConfig.typesToRead, typesToWrite: queryConfig.typesToWrite) { success, error in
			if let error = error {
				completion(nil, error)
			}
			else {
				guard let contractTimeRange = self.contractsCache.firstTimeRange(for: contractId) else {
					self.contractDetails(resultQueue: resultQueue) { contractResult in
						switch contractResult {
						case .success(let certificat):
							self.contractsCache.addTimeRanges(ranges: certificat.dataRequest?.timeRanges, for: contractId)
							let limits = certificat.verifyTimeRange(startDate: queryConfig.startDate, endDate: queryConfig.endDate)
							self.healthSerivce.readStatisticsCollectionQuery(from: limits.startDate,
																			 to: limits.endDate,
																			 anchorDate: queryConfig.anchorDate!,
																			 intervalComponents: queryConfig.intervalComponents!,
																			 for: queryConfig.typesToRead,
																			 mergeResultForSameType: queryConfig.mergeResultForSameType,
																			 singleCallbackForAllTypes: queryConfig.singleCallbackForAllTypes, completionHandler: completion)
							
						case .failure(let error):
							resultQueue.async {
								HealthKitService.reportErrorLog(error: error)
								completion(nil, error)
							}
						}
					}
					
					return
				}
				
				let limits = contractTimeRange.verifyTimeRange(startDate: queryConfig.startDate, endDate: queryConfig.endDate)
				
				self.healthSerivce.readStatisticsCollectionQuery(from: limits.startDate,
																 to: limits.endDate,
																 anchorDate: queryConfig.anchorDate!,
																 intervalComponents: queryConfig.intervalComponents!,
																 for: queryConfig.typesToRead,
																 mergeResultForSameType: queryConfig.mergeResultForSameType,
																 singleCallbackForAllTypes: queryConfig.singleCallbackForAllTypes, completionHandler: completion)
			}
		}
	}
    
#if targetEnvironment(simulator)
    public func saveHealthData(dataToSave: [HKObject], completion: @escaping (Result<Bool, SDKError>) -> Void) {
		self.healthSerivce.saveHealthData(dataToSave) { success, error in
            if success {
                completion(.success(success))
            }
            else {
                completion(.failure(.other))
            }
        }
    }
#endif
    
    // MARK: - Private
    
    private func readAccounts(session: Session, credentials: Credentials, completion: @escaping (Result<AccountsInfo, SDKError>) -> Void) {
		guard let jwt = JWTUtility.fileDownloadRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
			return completion(.failure(.errorCreatingRequestJwtToDownloadFile))
		}
		
		let route = ReadDataRoute(jwt: jwt, sessionKey: session.key, fileId: "accounts.json")
        apiClient.makeRequest(route) { result in
            switch result {
            case .success(let response):
                do {
					guard !response.data.isEmpty else {
						if LocalDataCache().deviceDataRequested {
							completion(.success(AccountsInfo(accounts: [HealthKitData().account], consentId: String.random(length: 32))))
						}
						else {
							completion(.failure(SDKError.readAccountsError))
						}
						return
					}

					let unpackedData = try self.dataDecryptor.decrypt(response: response, dataIsHashed: false)
					let accountsInfo = try unpackedData.decoded() as AccountsInfo
					
					if LocalDataCache().deviceDataRequested {
						var accounts = accountsInfo.accounts
						let consentId = accountsInfo.consentId
						accounts.append(HealthKitData().account)
						completion(.success(AccountsInfo(accounts: accounts, consentId: consentId)))
					}
					else {
						completion(.success(accountsInfo))
					}
                }
                catch let error as SDKError {
                    completion(.failure(error))
                }
                catch {
                    completion(.failure(SDKError.readAccountsError))
                }
            case .failure(let error):
				if LocalDataCache().deviceDataRequested {
					let info = AccountsInfo(accounts: [HealthKitData().account], consentId: String.random(length: 32))
					completion(.success(info))
				}
				else {
					completion(.failure(error))
				}
            }
        }
    }
    
    private func writePostbox(data: Data, metadata: Data, credentials: Credentials, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        uploadService.uploadFilePostbox(data: data, metadata: metadata, credentials: credentials) { result in
            switch result {
            case .success(let session):
                self.session = session
                completion(.success(credentials))
            case .failure(let error):
                // We should be pre-emptively catching the situation where the access token has expired,
                // but just in case we should react to server message
                switch error {
                case .httpResponseError(statusCode: 401, apiError: let apiError) where apiError?.code == "InvalidToken":
                    self.refreshTokens(credentials: credentials) { refreshResult in
                        switch refreshResult {
                        case .success(let credentials):
                            self.writePostbox(data: data, metadata: metadata, credentials: credentials, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                default:
                    completion(.failure(error))
                }
            }
        }
    }
	
	private func writeDirect(data: Data, metadata: RawFileMetadata, credentials: Credentials, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
		uploadService.uploadFileDirect(data: data, metadata: metadata, credentials: credentials) { result in
			switch result {
			case .success(let response):
				print(response)
				completion(.success(credentials))
			case .failure(let error):
				// We should be pre-emptively catching the situation where the access token has expired,
				// but just in case we should react to server message
				switch error {
				case .httpResponseError(statusCode: 401, apiError: let apiError) where apiError?.code == "InvalidToken":
					self.refreshTokens(credentials: credentials) { refreshResult in
						switch refreshResult {
						case .success(let credentials):
							self.writeDirect(data: data, metadata: metadata, credentials: credentials, completion: completion)
						case .failure(let error):
							completion(.failure(error))
						}
					}
				default:
					completion(.failure(error))
				}
			}
		}
	}
    
    // Auth - needs app to be able to receive response via URL
    private func beginAuth(serviceId: Int?, readOptions: ReadOptions?, linkToContractWithCredentials linkCredentials: Credentials?, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        
        // Ensure we don't have any session left over from previous
        session = nil
                
        authService.requestPreAuthorizationCode(readOptions: readOptions, accessToken: linkCredentials?.token.accessToken.value) { result in
            switch result {
            case .success(let response):
                self.session = response.session
                self.performAuth(preAuthResponse: response, serviceId: serviceId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Request read session by triggering source sync
    private func triggerSourceSync(credentials: Credentials, readOptions: ReadOptions?, completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard let jwt = JWTUtility.dataTriggerRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
            return completion(.failure(.errorCreatingRequestJwtToTriggerData))
        }

		apiClient.makeRequest(TriggerSyncRoute(jwt: jwt, readOptions: readOptions)) { result in
            switch result {
            case .success(let response):
                self.session = response.session
                completion(.success(Void()))

            case .failure(let error):
                // We should be pre-emptively catching the situation where the access token has expired,
                // but just in case we should react to server message
                switch error {
                case .httpResponseError(statusCode: 401, apiError: let apiError) where apiError?.code == "InvalidToken":
                    self.refreshTokens(credentials: credentials) { refreshResult in
                        switch refreshResult {
                        case .success(let refreshedCredentials):
                            self.triggerSourceSync(credentials: refreshedCredentials, readOptions: readOptions, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func validateOrRefreshCredentials(_ credentials: Credentials?, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        // Check we have credentials
        guard let credentials = credentials else {
            return completion(.failure(SDKError.authorizationRequired))
        }
        
        guard credentials.token.accessToken.isValid else {
            return refreshTokens(credentials: credentials, completion: completion)
        }
        
        completion(.success(credentials))
    }
    
    private func refreshTokens(credentials: Credentials, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        guard credentials.token.refreshToken.isValid else {
            return reauthorize(accessToken: credentials.token.accessToken, completion: completion)
        }
        
        authService.renewAccessToken(oauthToken: credentials.token) { result in
            switch result {
            case .success(let response):
                let newCredentials = Credentials(token: response, writeAccessInfo: credentials.writeAccessInfo)
                completion(.success(newCredentials))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func reauthorize(accessToken: OAuthToken.Token, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        authService.requestPreAuthorizationCode(readOptions: nil, accessToken: accessToken.value) { result in
            switch result {
            case .success(let response):
                self.session = response.session
                self.performAuth(preAuthResponse: response, serviceId: nil, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func performAuth(preAuthResponse: TokenSessionResponse, serviceId: Int?, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        consentManager.requestUserConsent(preAuthCode: preAuthResponse.token, serviceId: serviceId) { result in
            switch result {
            case .success(let response):
                self.exchangeToken(authResponse: response, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func exchangeToken(authResponse: ConsentResponse, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        authService.requestTokenExchange(authCode: authResponse.authorizationCode) { result in
            switch result {
            case .success(let response):
                let newCredentials = Credentials(token: response, writeAccessInfo: authResponse.writeAccessInfo)
                completion(.success(newCredentials))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func validateClient() -> SDKError? {
		#if !DEBUG
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return SDKError.noUrlScheme
        }
        
        let urlSchemes = urlTypes.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 }
        if !urlSchemes.contains("digime-ca-\(configuration.appId)") {
            return SDKError.noUrlScheme
        }
        
        if configuration.appId == "YOUR_APP_ID" {
            return SDKError.invalidAppId
        }
		#endif
        return nil
    }
    
    private func setupLogger() {
        let argonLogger = FileUploadService(apiClient: apiClient, configuration: configuration)

        let handler: LogHandler = { level, message, file, function, line, metadata in
            NSLog("[DigiMeSDK] [\(level.rawValue.uppercased())] \(message)")
            
            guard
                level == .mixpanel,
				let meta = metadata as? LogEventMeta else {
                return
            }
            
            argonLogger.uploadLog(logName: message, metadata: meta) { result in
                switch result {
                case .failure(let sdkerror):
					NSLog("[DigiMeSDK] error uploading logs: \(sdkerror)")
                default:
                    break
                }
            }
        }

        DigiMe.setLogHandler(handler)
    }
}
