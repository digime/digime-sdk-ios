//
//  OAuthService.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct Session: Codable {
    let expiry: Double
    let key: String
}

class OAuthService {
    
    private let configuration: Configuration
    private let apiClient: APIClient
    
    private var jwks: JSONWebKeySet?
    
    init(configuration: Configuration, apiClient: APIClient) {
        self.configuration = configuration
        self.apiClient = apiClient
    }
        
    // Can be used for raw response from server where `token` is the JWT
    // and as result when `token` is the extracted pre-authrozation code
    struct PreAuthResponse: Decodable {
        let token: String
        let session: Session
    }
    
    func requestPreAuthorizationCode(readOptions: ReadOptions?, accessToken: String? = nil, completion: @escaping (Result<PreAuthResponse, Error>) -> Void) {
        guard let jwt = JWTUtility.preAuthorizationRequestJWT(configuration: configuration, accessToken: accessToken) else {
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
    
    private struct AuthResponse: Decodable {
        let token: String
    }
    
    func requestTokenExchange(authCode: String, completion: @escaping (Result<OAuthToken, Error>) -> Void) {
        guard let jwt = JWTUtility.authorizationRequestJWT(authCode: authCode, configuration: configuration) else {
            fatalError("Invalid pre-authorization request JWT")
        }
        
        apiClient.makeRequest(.tokenExchange(jwt: jwt)) { [weak self] (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                self?.extractOAuthToken(from: response) { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func renewAccessToken(oauthToken: OAuthToken, completion: @escaping (Result<OAuthToken, Error>) -> Void) {
        guard let jwt = JWTUtility.refreshTokensRequestJWT(refreshToken: oauthToken.refreshToken.value, configuration: configuration) else {
            fatalError("Invalid pre-authorization request JWT")
        }
        
        apiClient.makeRequest(.tokenExchange(jwt: jwt)) { [weak self] (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                self?.extractOAuthToken(from: response) { result in
                    completion(result)
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
    
    private func extractOAuthToken(from response: AuthResponse, completion: @escaping (Result<OAuthToken, Error>) -> Void) {
        latestJsonWebKeySet { result in
            let newResult = result.flatMap { JWTUtility.oAuthToken(from: response.token, keySet: $0) }
            completion(newResult)
        }
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
