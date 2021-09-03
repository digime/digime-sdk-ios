//
//  CertificatePinner.swift
//  DigiMeSDK
//
//  Created on 12/08/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class CertificatePinner {
    
    let certificates: [Data]
    
    init() {
        let bundle = Bundle(for: Self.self)
        
        certificates = (1...5).compactMap {
            guard let url = bundle.url(forResource: "apiCert\($0)", withExtension: "der") else {
                return nil
            }
            
            return try? Data(contentsOf: url)
        }
    }
    
    func authenticate(challenge: URLAuthenticationChallenge) -> URLSession.AuthChallengeDisposition {
        return .performDefaultHandling
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return .cancelAuthenticationChallenge
        }
        
        guard SecTrustEvaluateWithError(serverTrust, nil) else {
            return .cancelAuthenticationChallenge
        }
    }
}
