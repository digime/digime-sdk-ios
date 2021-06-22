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
    var service: OAuthService?
    var consentManager: ConsentManager?
    let credentialCache: CredentialCache
    let apiClient: APIClient
    
    /// Initialises a new instance of SDK.
    /// A new instance should be created for each contract the app uses
    /// - Parameter configuration: The configuration which defines this instance
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.credentialCache = CredentialCache()
        self.apiClient = APIClient(credentialCache: credentialCache)
        self.service = OAuthService(configuration: configuration, apiClient: apiClient)
        self.consentManager = ConsentManager(configuration: configuration)
    }
    
    /// Blah blah - for dev purposes only
    public func testNewUser() {
        // Auth - needs app to be able to receive response via URL
        service?.requestPreAuthorizationCode(readOptions: nil) { result in
            if let response = try? result.get() {
                self.performAuth(preAuthResponse: response)
            }
        }
    }
    
    public func write(data: Data, metadata: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        apiClient.preflight { result in
            do {
                _ = try result.get()
            }
            catch {
                completion(.failure(error))
            }
            
            let symmetricalKey = Data() // [DMECryptoUtilities randomBytesWithLength:32]
            let iv = Data() // [DMECryptoUtilities randomBytesWithLength:16]
            
            let encryptedMetadata = "" // [DMECrypto encryptMetadata:metadata symmetricalKey:symmetricalKey initializationVector:iv]
            let payload = Data() // [DMECrypto encryptData:data symmetricalKey:symmetricalKey initializationVector:iv]
            let enxcyptedSymmetricalKey = "" // [DMECrypto encryptSymmetricalKey:symmetricalKey rsaPublicKey:postbox.postboxRSAPublicKey contractId:self.configuration.contractId]
            
            guard let credentials = self.credentialCache.contents else {
                return// completion(.failure(<#T##Error#>))
            }
            
            let jwt = JWTUtility.writeRequestJWT(accessToken: credentials.accessToken.value, iv: iv, metadata: encryptedMetadata, symmetricalKey: encryptedMetadata, configuration: self.configuration)
//            self.apiClient.makeRequest(.write(postboxId: "", payload: payload, jwt: jwt)) { (result: Result<Session, Error>) in
//                
//            }
        }
    }
    
    private func performAuth(preAuthResponse: OAuthService.PreAuthResponse) {
        consentManager?.requestUserConsent(preAuthCode: preAuthResponse.token, serviceId: nil) { result in
            do {
                let response = try result.get()
                self.exchangeToken(authResponse: response)
            }
            catch {
                print(error)
            }
        }
    }
    
    private func exchangeToken(authResponse: ConsentResponse) {
        service?.requestTokenExchange(authCode: authResponse.authorizationCode) { result in
            do {
                let response = try result.get()

                print(response)
            }
            catch {
                print(error)
            }
        }
    }
}
