//
//  StorageRetrieveRoute.swift
//  DigiMeSDK
//
//  Created on 15/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct StorageRetrieveRoute: Route {
    typealias ResponseType = StorageConfig

    static let method = "GET"
    static let path = "storage"

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
}
