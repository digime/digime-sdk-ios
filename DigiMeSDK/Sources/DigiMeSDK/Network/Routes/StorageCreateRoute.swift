//
//  StorageCreateRoute.swift
//  DigiMeSDK
//
//  Created on 09/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct StorageCreateRoute: Route {
    typealias ResponseType = StorageConfig

    static let method = "POST"
    static let path = "storage"

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
}
