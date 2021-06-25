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
    
    private var sessionDataCompletion: ((Result<FileList, Error>) -> Void)?
    private var sessionContentHandler: ((Result<File, Error>) -> Void)?
    
    private var isFetchingSessionData = false
    
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
    
    public func readFiles(downloadHandler: @escaping (Result<File, Error>) -> Void, completion: @escaping (Result<FileList, Error>) -> Void) {
        let credentials = credentialCache.credentials(for: configuration.contractId)!
        refreshSession(credentials: credentials, readOptions: nil) { result in
            do {
                let session = try result.get()
                
                self.sessionDataCompletion = completion
                self.sessionContentHandler = downloadHandler
                
                self.apiClient.makeRequest(ReadDataRoute(sessionKey: session.key, fileId: "accounts.json")) { result in
                    do {
                        let (data, fileInfo) = try result.get()
//                        guard
//                            let metadataBase64 = headers["X-Metadata"] as? String,
//                            let metadataData = Data(base64URLEncoded: metadataBase64) else {
//                            return completion(.failure(SDKError.invalidData))
//                        }

                        let unpackedData = try self.dataDecryptor.decrypt(fileContent: data)
                        let decompressed = try DataCompressor.gzip.decompress(data: data)
                        let stringData = String(data: data, encoding: .utf8)
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
    
    public func readFileList(completion: @escaping (Result<AccountsInfo, Error>) -> Void) {
        let credentials = credentialCache.credentials(for: configuration.contractId)!
        refreshSession(credentials: credentials, readOptions: nil) { result in
            do {
                let session = try result.get()
                self.apiClient.makeRequest(ReadDataRoute(sessionKey: session.key, fileId: "accounts.json")) { result in
                    do {
                        let (data, fileInfo) = try result.get()
//                        guard
//                            let metadataBase64 = headers["X-Metadata"] as? String,
//                            let metadataData = Data(base64URLEncoded: metadataBase64) else {
//                            return completion(.failure(SDKError.invalidData))
//                        }

                        let unpackedData = try self.dataDecryptor.decrypt(fileContent: data)
                        let decompressed = try DataCompressor.gzip.decompress(data: data)
                        let stringData = String(data: data, encoding: .utf8)
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
        
        isFetchingSessionData = true
        
    }
}
