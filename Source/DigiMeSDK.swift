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
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func testNewUser() {
        // During dev, this allows use to test flow inrementally
        let apiClient = APIClient()
        service = OAuthService(configuration: configuration, apiClient: apiClient)
        
        // Auth - needs app to be able to receive response via URL
        service!.requestPreAuthorizationCode(readOptions: nil) { result in
            if let response = try? result.get() {
                var components = URLComponents(string: "https://api.development.devdigi.me/apps/saas/authorize")!
                components.percentEncodedQueryItems = [
                    .init(name: "code", value: response.token),
                    .init(name: "errorCallback", value: "\(self.configuration.redirectUri)error".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
                    .init(name: "successCallback", value: "\(self.configuration.redirectUri)auth".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
                ]
                let url = components.url!
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:]) { success in
                        let mce = 0
                    }
                }
            }
        }
        
        let authCode = "862de8e4307f988164dee825008af37c1799597d60d755b2362e8a905070b7ac08a8e0dcb5e538377c66ba3c7326ce5a51d8bc71eca66a470301a3204ada425108eb5e9b5e131b1faa998e05a147424f"
    }
}
