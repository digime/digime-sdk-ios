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
    
    /// Initialises a new instance of SDK.
    /// A new instance should be created for each contract the app uses
    /// - Parameter configuration: The configuration which defines this instance
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    /// Blah blah - for dev purposes only
    public func testNewUser() {
        // During dev, this allows use to test flow inrementally
        let apiClient = APIClient()
        service = OAuthService(configuration: configuration, apiClient: apiClient)
        consentManager = ConsentManager(configuration: configuration)
        
        // Auth - needs app to be able to receive response via URL
        service?.requestPreAuthorizationCode(readOptions: nil) { result in
            if let response = try? result.get() {
                self.peformAuth(preAuthResponse: response)
            }
        }
    }
    
    private func peformAuth(preAuthResponse: OAuthService.PreAuthResponse) {
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
