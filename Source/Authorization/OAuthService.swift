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
    
    init(configuration: Configuration, apiClient: APIClient) {
        self.configuration = configuration
        self.apiClient = apiClient
    }
    
    func requestPreAuthorizationCode(publicKey: String?, completion: (Result<String, Error>) -> Void) {
        
    }
    
    func requestTokenExchange(authCode: String, publicKey: String?, completion: (Result<String, Error>) -> Void) {
        
    }
}
