//
//  APIConfig.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum APIConfig {
    static let baseURLPath = "https://api.development.devdigi.me"
    static let baseURLPathWithVersion = baseURLPath + "/v1.6"
    
    static var agent: Agent = {
        let version = Bundle(for: APIClient.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return Agent(name: "ios", version: version)
    }()
}
