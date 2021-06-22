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
    
    // dev only?
    var authService: OAuthService
    var consentManager: ConsentManager
    let credentialCache: CredentialCache
    let apiClient: APIClient
    
    /// Initialises a new instance of SDK.
    /// A new instance should be created for each contract the app uses
    /// - Parameter configuration: The configuration which defines this instance
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.credentialCache = CredentialCache()
        self.apiClient = APIClient(credentialCache: credentialCache)
        self.authService = OAuthService(configuration: configuration, apiClient: apiClient)
        self.consentManager = ConsentManager(configuration: configuration)
    }
    
    /// Blah blah - for dev purposes only
    public func testNewUser(completion: @escaping (Error?) -> Void) {
        // Auth - needs app to be able to receive response via URL
        authService.requestPreAuthorizationCode(readOptions: nil) { result in
            if let response = try? result.get() {
                self.performAuth(preAuthResponse: response) { result in
                    switch result {
                    case .success():
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
        }
    }
    
    public func write(data: Data, metadata: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        preflight { result in
            do {
                _ = try result.get()
            }
            catch {
                completion(.failure(error))
            }
            
            guard
                let credentials = self.credentialCache.credentials(for: self.configuration.contractId),
                let writeAccessInfo = credentials.writeAccessInfo else {
                return// completion(.failure(<#T##Error#>)) // What error should we return?
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
                
                self.apiClient.makeRequest(.write(postboxId: writeAccessInfo.postboxId, payload: payload, jwt: jwt)) { (result: Result<Session, Error>) in
                    completion(result.map { _ in Void() })
                }
            }
            catch {
                return completion(.failure(error))
            }
        }
    }
    
    // Only needed for data read/writes
    private func preflight(completion: @escaping (Result<Void, Error>) -> Void) {
        // Check we have credentials
        guard let credentials = credentialCache.credentials(for: configuration.contractId) else {
            return completion(.failure(SDKError.authenticationRequired))
        }
        
        guard credentials.token.accessToken.isValid else {
            return refreshTokens(credentials: credentials, completion: completion)
        }
        
        completion(.success(()))
    }
    
    private func refreshTokens(credentials: Credentials, completion: @escaping (Result<Void, Error>) -> Void) {
        guard credentials.token.refreshToken.isValid else {
            return reauthorize(accessToken: credentials.token.accessToken, completion: completion)
        }
        
        authService.renewAccessToken(oauthToken: credentials.token) { result in
            do {
                let response = try result.get()
                let newCredentials = Credentials(token: response, writeAccessInfo: credentials.writeAccessInfo)
                self.credentialCache.setCredentials(newCredentials, for: self.configuration.contractId)
                print(response)
                completion(.success(()))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    private func reauthorize(accessToken: OAuthToken.Token, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.requestPreAuthorizationCode(readOptions: nil, accessToken: accessToken.value) { result in
            do {
                let response = try result.get()
                self.performAuth(preAuthResponse: response, completion: completion)
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    private func performAuth(preAuthResponse: OAuthService.PreAuthResponse, completion: @escaping (Result<Void, Error>) -> Void) {
        consentManager.requestUserConsent(preAuthCode: preAuthResponse.token, serviceId: nil) { result in
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
    
    private func exchangeToken(authResponse: ConsentResponse, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.requestTokenExchange(authCode: authResponse.authorizationCode) { result in
            do {
                let response = try result.get()
                let credentials = Credentials(token: response, writeAccessInfo: authResponse.writeAccessInfo)
                self.credentialCache.setCredentials(credentials, for: self.configuration.contractId)
                print(response)
                completion(.success(()))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
}
