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
        
    // TokenSessionResponse can be used for raw response from server where `token` is the JWT
    // and as result when `token` is the extracted pre-authrozation code
    func requestPreAuthorizationCode(readOptions: ReadOptions?, accessToken: String?, completion: @escaping (Result<TokenSessionResponse, SDKError>) -> Void) {
        guard let jwt = JWTUtility.preAuthorizationRequestJWT(configuration: configuration, accessToken: accessToken) else {
            Logger.critical("Invalid pre-authorization request JWT")
            completion(.failure(SDKError.invalidPreAuthorizationRequestJwt))
            return
        }
		
		let route = AuthorizeRoute(jwt: jwt, readOptions: readOptions)
        apiClient.makeRequest(route) { [weak self] result in
            switch result {
            case .success(let response):
                self?.extractPreAuthorizationCode(from: response) { result in
                    completion(result.map { TokenSessionResponse(token: $0, session: response.session) })
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestTokenExchange(authCode: String, completion: @escaping (Result<OAuthToken, SDKError>) -> Void) {
        guard let jwt = JWTUtility.authorizationRequestJWT(authCode: authCode, configuration: configuration) else {
            Logger.critical("Invalid authorization request JWT")
            completion(.failure(SDKError.invalidAuthorizationRequestJwt))
            return
        }

		apiClient.makeRequest(TokenExchangeRoute(jwt: jwt)) { [weak self] result in
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
    
    func renewAccessToken(oauthToken: OAuthToken, completion: @escaping (Result<OAuthToken, SDKError>) -> Void) {
        guard let jwt = JWTUtility.refreshTokensRequestJWT(refreshToken: oauthToken.refreshToken.value, configuration: configuration) else {
            Logger.critical("Invalid refresh tokens request JWT")
            completion(.failure(SDKError.invalidRefreshTokensRequestJwt))
            return
        }

		apiClient.makeRequest(TokenExchangeRoute(jwt: jwt)) { [weak self] result in
            switch result {
            case .success(let response):
                self?.extractOAuthToken(from: response) { result in
                    completion(result)
                }
            case .failure(let error):
                switch error {
                case .httpResponseError(statusCode: 401, apiError: let apiError) where apiError?.code == "InvalidToken":
                    completion(.failure(.authorizationRequired))
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    func requestReferenceToken(oauthToken: OAuthToken, completion: @escaping (Result<TokenSessionResponse, SDKError>) -> Void) {
        guard let jwt = JWTUtility.requestTokenReferenceJWT(accessToken: oauthToken.accessToken.value, configuration: configuration) else {
            Logger.critical("Invalid reference token request JWT")
            completion(.failure(SDKError.invalidReferenceTokenRequestJwt))
            return
        }

		apiClient.makeRequest(TokenReferenceRoute(jwt: jwt)) { [weak self] result in
            switch result {
            case .success(let response):
                self?.extractReferenceCode(from: response) { result in
                    completion(result.map { TokenSessionResponse(token: $0, session: response.session) })
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteUser(oauthToken: OAuthToken, completion: @escaping (Result<Void, SDKError>) -> Void) {
        guard let jwt = JWTUtility.fileDownloadRequestJWT(accessToken: oauthToken.accessToken.value, configuration: configuration) else {
            Logger.critical("Invalid delete user token request JWT")
            completion(.failure(SDKError.invalidDeleteUserTokenRequestJwt))
            return
        }

		apiClient.makeRequest(DeleteUserRoute(jwt: jwt), completion: completion)
    }
    
    private func extractPreAuthorizationCode(from response: TokenSessionResponse, completion: @escaping (Result<String, SDKError>) -> Void) {
        latestJsonWebKeySet { result in
            let newResult = result.flatMap { JWTUtility.preAuthCode(from: response.token, keySet: $0) }
            completion(newResult)
        }
    }
    
    private func extractOAuthToken(from response: AuthResponse, completion: @escaping (Result<OAuthToken, SDKError>) -> Void) {
        latestJsonWebKeySet { result in
            let newResult = result.flatMap { JWTUtility.oAuthToken(from: response.token, keySet: $0) }
            completion(newResult)
        }
    }
    
    private func extractReferenceCode(from response: TokenSessionResponse, completion: @escaping (Result<String, SDKError>) -> Void) {
        latestJsonWebKeySet { result in
            let newResult = result.flatMap { JWTUtility.referenceCode(from: response.token, keySet: $0) }
            completion(newResult)
        }
    }
    
    private func latestJsonWebKeySet(completion: @escaping (Result<JSONWebKeySet, SDKError>) -> Void) {
        if
            let jwks = jwks,
            jwks.isValid {
            completion(.success(jwks))
            return
        }
        
        apiClient.makeRequest(WebKeySetRoute()) { result in
            if let jwks = try? result.get() {
                self.jwks = jwks
            }

            completion(result)
        }
    }
}
