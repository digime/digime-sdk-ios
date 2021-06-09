//
//  OAuthService.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class OAuthService {
    
    private let configuration: Configuration
    private let apiClient: APIClient
    
    private var jwks: JSONWebKeySet?
    
    init(configuration: Configuration, apiClient: APIClient) {
        self.configuration = configuration
        self.apiClient = apiClient
    }
    
    struct Session: Decodable {
        let expiry: Double
        let key: String
    }
    
    struct PreAuthResponse: Decodable {
        let token: String
        let session: Session
    }
    
    func requestPreAuthorizationCode(publicKey: String?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let jwt = JWTUtility.preAuthorizationRequestJWT(configuration: configuration) else {
            fatalError("Invalid pre-authorization request JWT")
        }

        apiClient.makeRequest(.authorize(jwt: jwt, agent: apiClient.agent, readOptions: readOptions)) { [weak self] (result: Result<PreAuthResponse, Error>) in
            switch result {
            case .success(let response):
                self?.extractPeAuthorizationCode(from: response) { result in
                    completion(result.map { PreAuthResponse(token: $0, session: response.session) })
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func extractPeAuthorizationCode(from response: PreAuthResponse, completion: @escaping (Result<String, Error>) -> Void) {
        latestJsonWebKeySet { result in
            let newResult = result.flatMap { JWTUtility.preAuthCode(from: response.token, keySet: $0) }
            completion(newResult)
        }
    }
    
    func requestTokenExchange(authCode: String, publicKey: String?, completion: (Result<PreAuthResponse, Error>) -> Void) {
    }
    
    private func latestJsonWebKeySet(completion: @escaping (Result<JSONWebKeySet, Error>) -> Void) {
        if
            let jwks = jwks,
            jwks.isValid {
            completion(.success(jwks))
            return
        }
        
        apiClient.makeRequest(.jwks) { (result: Result<JSONWebKeySet, Error>) in
            if let jwks = try? result.get() {
                self.jwks = jwks
            }
            
            completion(result)
        }
    }
}

struct JSONWebKey: Decodable {
    let e: String // RSA public exponent
    let kid: String // Key identifier
    let kty: String // Key type identifies the cryptographic algorithm family used with the key, such as 'RSA' or 'EC'
    let n: String // RSA Modulus
    let pem: String // PCKS1 public pem encoded publkic key representation
}

struct JSONWebKeySet: Decodable {
    let keys: [JSONWebKey]
    let date = Date()
    
    // Cache for 15 minutes
    var isValid: Bool {
        Date() < date.addingTimeInterval(15*60)
    }
}
