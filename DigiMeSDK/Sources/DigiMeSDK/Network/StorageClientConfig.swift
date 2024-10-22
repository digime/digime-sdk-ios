//
//  StorageClientConfig.swift
//  DigiMeSDK
//
//  Created on 10/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

enum StorageClientConfig {
    static let version = "/v1"
    static let baseUrl = "https://cloud.digi.me"
    static let baseUrlPathWithVersion = baseUrl + version

    static var agent: Agent = {
        let appVersion = Bundle(for: APIClient.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return Agent(name: "ios", version: appVersion)
    }()
}

