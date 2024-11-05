//
//  APIConfig.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

enum APIConfig {
    static let baseUrl = "https://api.digi.me"
    
    static var agent: Agent = {
        let appVersion = Bundle(for: APIClient.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return Agent(name: "ios", version: appVersion)
    }()
}
