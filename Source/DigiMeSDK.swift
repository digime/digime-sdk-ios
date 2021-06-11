//
//  DigiMeSDK.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public class DigiMeSDK {
    
    private let configuration: Configuration
    
    // dev only?
    var service: OAuthService?
    var consentManager: ConsentManager?
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func testNewUser() {
        // During dev, this allows use to test flow inrementally
        let apiClient = APIClient()
        service = OAuthService(configuration: configuration, apiClient: apiClient)
        consentManager = ConsentManager(configuration: configuration)
        
        // Auth - needs app to be able to receive response via URL
        service!.requestPreAuthorizationCode(readOptions: nil) { result in
            if let response = try? result.get() {
                self.peformAuth(preAuthResponse: response)
            }
        }
        
        let authCode = "862de8e4307f988164dee825008af37c1799597d60d755b2362e8a905070b7ac08a8e0dcb5e538377c66ba3c7326ce5a51d8bc71eca66a470301a3204ada425108eb5e9b5e131b1faa998e05a147424f"
    }
    
    private func peformAuth(preAuthResponse: OAuthService.PreAuthResponse) {
        consentManager?.requestUserConsent(preAuthCode: preAuthResponse.token, serviceId: nil) { result in
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
