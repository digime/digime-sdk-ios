//
//  DigiMe.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

#if canImport(DigiMeHealthKit)
import DigiMeHealthKit
#endif

import DigiMeCore
import Foundation

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
#if canImport(DigiMeHealthKit)
	private let healthSerivce: HealthKitService
#endif
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
#if canImport(DigiMeHealthKit)
		self.healthSerivce = HealthKitService()
#endif
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
    ///   - sampleDataSetId: Sample Dataset ID to use for sample data onboarding.
    ///   - sampleDataAutoOnboard: Skip consent swipe screen for sample data onboarding.
    ///   - readOptions: Options to filter which data is read from sources for this session. Only used for read contracts.
    ///   - linkToContractWithCredentials: When specified, connects to same library as another contract.  Does nothing if user has already authorized this contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon authorization completion with new or refreshed credentials, or any errors encountered.
    public func authorize(credentials: Credentials? = nil, serviceId: Int? = nil, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil, readOptions: ReadOptions? = nil, linkToContractWithCredentials linkCredentials: Credentials? = nil, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
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
                self.beginAuth(serviceId: serviceId, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataAutoOnboard, readOptions: readOptions, linkToContractWithCredentials: linkCredentials) { authResult in
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
	
	/// In cases where access to a service's data is revoked and you receive an error message of `511 Service Authorization Required` you can initiate the reauthentication process by requesting the re-authentication URL and directing the user to it.
	/// - Parameters:
	///   - accountId: Service account entity identifier.
	///   - credentials: The existing credentials for the contract.
	///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
	///   - completion: Block called upon completion with new or refreshed credentials, or any errors encountered.
	public func reauthorizeAccount(accountId: String, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
		validateOrRefreshCredentials(credentials) { credResult in
			switch credResult {
			case .success(let refreshedCredentials):
				self.authService.requestReferenceToken(oauthToken: refreshedCredentials.token) { refTokenResult in
					switch refTokenResult {
					case .success(let response):
						self.session = response.session
						self.authService.requestAccountReference(accountId: accountId) { refAccountResult in
							switch refAccountResult {
							case .success(let accountRef):
                                self.consentManager.reauthService(accountRef: accountRef.id, token: response.token) { result in
                                    resultQueue.async {
                                        switch result {
                                        case .success:
                                            completion(refreshedCredentials, .success(()))
                                        case .failure(let error):
                                            completion(refreshedCredentials, .failure(error))
                                        }
                                    }
								}
								
							case .failure(let error):
								resultQueue.async {
									completion(refreshedCredentials, .failure(error))
								}
							}
						}
						
					case .failure(let error):
						resultQueue.async {
							completion(refreshedCredentials, .failure(error))
						}
					}
				}
				
			case .failure(let error):
				resultQueue.async {
					completion(credentials, .failure(error))
				}
			}
		}
	}
	
    /// Authorizes the contract to support the storing of user entered data in a digime library with store, edit and delete functionality.
    /// - Parameters:
    ///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with new or refreshed credentials, or any errors encountered.
    public func authorizeServiceToPushData(credentials: Credentials? = nil, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        
        if let validationError = validateClient() {
            resultQueue.async {
                completion(.failure(validationError))
            }
            return
        }
        
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success, .failure(SDKError.authorizationRequired):
                self.beginAuth(serviceId: nil, readOptions: nil, linkToContractWithCredentials: nil, onlyPushServices: true) { authResult in
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
    ///   - sampleDataSetId: Sample Dataset ID to use for sample data onboarding.
    ///   - sampleDataAutoOnboard: Skip consent swipe screen for sample data onboarding.
    ///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue which the completion block will be called on. Defaults to main dispatch queue.
    ///   - completion: Block called upon completion with new or refreshed credentials, or any errors encountered
    public func addService(identifier: Int, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
            self.authService.requestReferenceToken(oauthToken: refreshedCredentials.token) { result in
                switch result {
                case .success(let response):
                    self.session = response.session
                    self.consentManager.addService(identifier: identifier, token: response.token) { result in
                        switch result {
                        case .success:
                            resultQueue.async {
                                completion(refreshedCredentials, .success(()))
                            }
                        case .failure(let error):
                            resultQueue.async {
                                completion(refreshedCredentials, .failure(error))
                            }
                        }
                    }
                
                case .failure(let error):
                    resultQueue.async {
                        completion(refreshedCredentials, .failure(error))
                    }
                }
            }
                
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
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
    public func readAccounts(credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<[SourceAccountData], SDKError>) -> Void) {
        guard
            let session = session,
            session.isValid else {
            return completion(credentials, .failure(.invalidSession))
        }
        
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.readAccounts(credentials: refreshedCredentials) { result in
                    resultQueue.async {
                        completion(refreshedCredentials, result)
                    }
                }
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
                }
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
    public func readAllFiles(credentials: Credentials, readOptions: ReadOptions?, resultQueue: DispatchQueue = .main, downloadHandler: @escaping (Result<File, SDKError>) -> Void, completion: @escaping (Credentials, Result<FileList, SDKError>) -> Void) {
        guard allFilesReader == nil else {
            resultQueue.async {
                completion(credentials, .failure(SDKError.alreadyReadingAllFiles))
            }
            return
        }
#if canImport(DigiMeHealthKit)
		allFilesReader = AllFilesReader(apiClient: self.apiClient,
										credentials: credentials,
										healthSerivce: self.healthSerivce,
										certificateParser: self.certificateParser,
										contractsCache: self.contractsCache,
										configuration: self.configuration,
										readOptions: readOptions)
#else
        allFilesReader = AllFilesReader(apiClient: self.apiClient,
                                        credentials: credentials,
                                        certificateParser: self.certificateParser,
                                        contractsCache: self.contractsCache,
                                        configuration: self.configuration,
                                        readOptions: readOptions)
#endif
        
        allFilesReader?.readAllFiles(downloadHandler: { result in
            resultQueue.async {
                downloadHandler(result)
            }
        }, completion: { result in
            if case .failure(.invalidSession) = result {
                self.requestDataQuery(credentials: credentials, readOptions: readOptions, resultQueue: DispatchQueue.global()) { refreshedCredentials, result in
                    switch result {
                    case .success:
                        self.allFilesReader?.readAllFiles(downloadHandler: { result in
                            resultQueue.async {
                                downloadHandler(result)
                            }
                        }, completion: { result in
                            self.allFilesReader = nil
                            resultQueue.async {
                                completion(refreshedCredentials, result)
                            }
                        })
                        
                    case .failure(let error):
                        self.allFilesReader = nil
                        resultQueue.async {
                            completion(refreshedCredentials, .failure(error))
                        }
                    }
                }
                
                return
            }
            
            self.allFilesReader = nil
            resultQueue.async {
                completion(credentials, result)
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
    public func requestDataQuery(credentials: Credentials, readOptions: ReadOptions?, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.triggerSourceSync(credentials: refreshedCredentials, readOptions: readOptions, completion: completion)
                
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
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
    public func readFileList(credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<FileList, SDKError>) -> Void) {
        guard
            let session = session,
            session.isValid else {
            return completion(credentials, .failure(.invalidSession))
        }
        
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                guard let jwt = JWTUtility.dataRequestJWT(accessToken: refreshedCredentials.token.accessToken.value, configuration: self.configuration) else {
                    return completion(refreshedCredentials, .failure(.errorCreatingDataRequestJwt))
                }
                
                let route = FileListRoute(jwt: jwt, sessionKey: session.key)
                self.apiClient.makeRequest(route) { result in
                    resultQueue.async {
                        completion(refreshedCredentials, result)
                    }
                }
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
                }
            }
        }
    }
    
    /// Retrieves the content of a specified file.
    ///
    /// Requires a valid session to have been created, either implicitly by adding a new service, or explicitly by calling `requestDataQuery(credentials:readOptions:resultQueue:completion)`.
    ///
    /// - Parameters:
    ///  - fileId: The file's identifier.
    ///  - credentials: The existing credentials for the contract.
    ///  - resultQueue: The dispatch queue which the download handler and completion blocks will be called on. Defaults to main dispatch queue.
    ///  - completion: Block called upon completion with file, or any errors encountered.
    public func readFile(fileId: String, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<File, SDKError>) -> Void) {
        guard
            let session = session,
            session.isValid else {
            return completion(credentials, .failure(.invalidSession))
        }
        
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.downloadService.downloadFile(fileId: fileId, sessionKey: session.key, credentials: refreshedCredentials, configuration: self.configuration) { result in
                    resultQueue.async {
                        completion(refreshedCredentials, result)
                    }
                }
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
                }
            }
        }
    }
	
    /// Retrieves sample data sets for a specific service by its identifier.
    ///
    /// This function facilitates the integration process by providing sample data sets that represent what actual data from the service would look like. 
    /// It allows developers to test and demonstrate their application's functionality without the need to connect to real service accounts such as Facebook or Twitter.
    /// This can be particularly useful for demonstrations, testing, or when real account access is not available or not desired.
    ///
    /// The function asynchronously fetches the data and returns a dictionary containing sample data set IDs as keys and `SampleDataset` objects as values. 
    /// The `SampleDataset` objects include placeholders for properties like descriptions, names, and any other relevant information to the service.
    ///
    /// - Parameters:
    ///   - serviceId: A string identifier for the service for which to retrieve sample data sets. This ID should correspond to one of the services known to the SDK.
    ///   - resultQueue: The `DispatchQueue` on which the completion handler is dispatched. By default, this parameter is set to the main queue.
    ///   - completion: A closure that is called upon completion of the request. It provides a `Result` type that contains either a dictionary of sample data sets on success or an `SDKError` on failure.
    public func fetchDemoDataSetsInfoForService(serviceId: String, resultQueue: DispatchQueue = .main, completion: @escaping (Result<[String: SampleDataset], SDKError>) -> Void) {
        guard let jwt = JWTUtility.basicRequestJWT(configuration: configuration) else {
            Logger.critical("Invalid sample data request JWT")
            completion(.failure(SDKError.invalidAccountReferenceRequestJwt))
            return
        }
        
        let route = ReadSampleDataSetsRoute(jwt: jwt, serviceId: serviceId)
        
        apiClient.makeRequest(route) { result in
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
    public func pushDataToLibrary(data: Data, metadata: RawFileMetadata, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
		validateOrRefreshCredentials(credentials) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.writeDirect(data: data, metadata: metadata, credentials: refreshedCredentials, completion: completion)
			
			case .failure(let error):
				resultQueue.async {
					completion(credentials, .failure(error))
				}
			}
		}
	}
    
    /// Writes data to the authorized provider.
    /// - Parameters:
    ///   - payload: The data to be pushed to the provider.
    ///   - accountId: A unique reference to a selected account for PUSH, retrieved via the authorization endpoint.
    ///   - standard: The FHIR standard being used.
    ///   - version: The version of the FHIR standard, such as 'stu3' or '3.0.2'.
    ///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue on which the completion block will be called. Defaults to the main dispatch queue.
    ///   - completion: A block called upon completion with either the successful result or any errors encountered.
    public func pushDataToProvider(payload: Data, accountId: String, standard: String, version: String, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Data, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.pushDataToProvider(payload: payload, accountId: accountId, standard: standard, version: version, credentials: refreshedCredentials, completion: completion)
                
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
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
    public func deleteUser(credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.authService.deleteUser(oauthToken: refreshedCredentials.token) { result in
                    self.session = nil
                    resultQueue.async {
                        switch result {
                        case .success:
                            completion(refreshedCredentials, .success(()))
                        case .failure(let error):
                            completion(refreshedCredentials, .failure(error))
                        }
                    }
                }
            
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
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
	public func clearCachedData(for contractId: String? = nil) {
		guard let contractId = contractId else {
			ContractsCache().reset()
			LocalDataCache().reset()
			return
		}
		
		allFilesReader?.clearSessionData()
		CredentialCache().clearCredentials(for: contractId)
		SessionCache().clearSession(for: contractId)
		ContractsCache().clearTimeRanges(for: contractId)
		LocalDataCache().removeRequestOfLocalData(for: contractId)
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
    
    
    /// The Portability Report is a report through which an individual is informed by their Individual's Service Provider about the health information that
    /// the individual has collected from providers in the digi.me application. This allows the individual to supplement another or
    /// a new personal health environment (PHE) with the same collection actions.
    /// - Parameters:
    ///   - serviceTypeName: Service type name, such as 'medmij'
    ///   - format: File format, such as 'xml'
    ///   - from: Start date in the format of a timestamp in seconds.
    ///   - to: End date in the format of a timestamp in seconds.
    ///   - credentials: The existing credentials for the contract.
    ///   - resultQueue: The dispatch queue on which the completion block will be called. Defaults to the main dispatch queue.
    ///   - completion: Block called upon completion with either the report data or any errors encountered.
    public func exportPortabilityReport(for serviceTypeName: String, format: String, from: TimeInterval, to: TimeInterval, credentials: Credentials, resultQueue: DispatchQueue = .main, completion: @escaping (Credentials, Result<Data, SDKError>) -> Void) {
        validateOrRefreshCredentials(credentials) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.exportData(for: serviceTypeName, format: format, from: from, to: to, credentials: refreshedCredentials) { result in
                    self.session = nil
                    resultQueue.async {
                        completion(refreshedCredentials, result)
                    }
                }
                
            case .failure(let error):
                resultQueue.async {
                    completion(credentials, .failure(error))
                }
            }
        }
    }
    
    // MARK: - Apple Health
    
#if canImport(DigiMeHealthKit)
    public func addTestData(completion: @escaping (Result<Bool, SDKError>) -> Void) {
		healthSerivce.addTestData { success, error in
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
    
    private func readAccounts(credentials: Credentials, completion: @escaping (Result<[SourceAccountData], SDKError>) -> Void) {
        guard let jwt = JWTUtility.dataRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
            return completion(.failure(.errorCreatingDataRequestJwt))
        }
        
        let route = ConnectedAccountsRoute(jwt: jwt)
        apiClient.makeRequest(route) { result in
            switch result {
            case .success(var accounts):
                if LocalDataCache().isDeviceDataRequested(for: self.configuration.contractId) {
#if canImport(DigiMeHealthKit)
                    accounts.append(HealthKitAccountDataProvider().sourceAccountData)
#endif
                    completion(.success(accounts))
                }
                else {
                    completion(.success(accounts))
                }
            case .failure(let error):
                if LocalDataCache().isDeviceDataRequested(for: self.configuration.contractId) {
#if canImport(DigiMeHealthKit)
                    completion(.success([HealthKitAccountDataProvider().sourceAccountData]))
#endif
                }
                else {
                    completion(.failure(error))
                }
            }
        }
    }
	
	private func writeDirect(data: Data, metadata: RawFileMetadata, credentials: Credentials, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
		uploadService.uploadFileDirect(data: data, metadata: metadata, credentials: credentials) { result in
			switch result {
			case .success:
				completion(credentials, .success(()))
			case .failure(let error):
				// We should be pre-emptively catching the situation where the access token has expired,
				// but just in case we should react to server message
				switch error {
				case .httpResponseError(statusCode: 401, apiError: let apiError) where apiError?.code == "InvalidToken":
					self.refreshTokens(credentials: credentials) { refreshResult in
						switch refreshResult {
						case .success(let refreshedCredentials):
							self.writeDirect(data: data, metadata: metadata, credentials: refreshedCredentials, completion: completion)
						case .failure(let error):
							completion(credentials, .failure(error))
						}
					}
				default:
					completion(credentials, .failure(error))
				}
			}
		}
	}
    
    private func pushDataToProvider(payload: Data, accountId: String, standard: String, version: String, credentials: Credentials, completion: @escaping (Credentials, Result<Data, SDKError>) -> Void) {
        guard let jwt = JWTUtility.dataRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
            return completion(credentials, .failure(.errorCreatingDataRequestJwt))
        }

        let route = PushDataToProviderRoute(jwt: jwt, accountId: accountId, standard: standard, version: version, payload: payload)
        apiClient.makeRequest(route) { result in
            completion(credentials, result)
        }
    }
    
    private func exportData(for serviceTypeName: String, format: String, from: TimeInterval, to: TimeInterval, credentials: Credentials, completion: @escaping (Result<Data, SDKError>) -> Void) {
        guard let jwt = JWTUtility.dataRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
            return completion(.failure(.errorCreatingRequestJwtToExportReport))
        }
        
        let route = ExportReportDataRoute(jwt: jwt, serviceTypeName: serviceTypeName, format: format, from: from, to: to)
        apiClient.makeRequest(route) { result in
            completion(result)
        }
    }
    
    // MARK: - Auth & Refresh
    
    // Auth - needs app to be able to receive response via URL
    private func beginAuth(serviceId: Int?, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil, readOptions: ReadOptions?, linkToContractWithCredentials linkCredentials: Credentials?, onlyPushServices: Bool = false, completion: @escaping (Result<Credentials, SDKError>) -> Void) {

        // Ensure we don't have any session left over from previous
        session = nil
                
        authService.requestPreAuthorizationCode(readOptions: readOptions, accessToken: linkCredentials?.token.accessToken.value) { result in
            switch result {
            case .success(let response):
                self.session = response.session
                self.performAuth(preAuthResponse: response, serviceId: serviceId, onlyPushServices: onlyPushServices, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataAutoOnboard, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Request read session by triggering source sync
    private func triggerSourceSync(credentials: Credentials, readOptions: ReadOptions?, completion: @escaping (Credentials, Result<Void, SDKError>) -> Void) {
        guard let jwt = JWTUtility.dataRequestJWT(accessToken: credentials.token.accessToken.value, configuration: configuration) else {
            return completion(credentials, .failure(.errorCreatingRequestJwtToTriggerData))
        }

		apiClient.makeRequest(TriggerSyncRoute(jwt: jwt, readOptions: readOptions)) { result in
            switch result {
            case .success(let response):
                self.session = response.session
                completion(credentials, .success(Void()))

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
                            completion(credentials, .failure(error))
                        }
                    }
                default:
                    completion(credentials, .failure(error))
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
    
    private func performAuth(preAuthResponse: TokenSessionResponse, serviceId: Int?, onlyPushServices: Bool = false, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil, completion: @escaping (Result<Credentials, SDKError>) -> Void) {
        consentManager.requestUserConsent(preAuthCode: preAuthResponse.token, serviceId: serviceId, onlyPushServices: onlyPushServices, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataAutoOnboard) { result in
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
                let newCredentials = Credentials(token: response, writeAccessInfo: authResponse.writeAccessInfo, accountReference: authResponse.accountReference)
                completion(.success(newCredentials))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Utils
    
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