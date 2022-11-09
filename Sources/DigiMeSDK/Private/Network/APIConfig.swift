//
//  APIConfig.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum APIConfig {
	static let version = "/v1.7"
    static let baseUrl = "https://api.digi.me"
	static let baseUrlPathWithVersion = baseUrl + version
    
    static var agent: Agent = {
        let appVersion = Bundle(for: APIClient.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return Agent(name: "ios", version: appVersion)
    }()
}
