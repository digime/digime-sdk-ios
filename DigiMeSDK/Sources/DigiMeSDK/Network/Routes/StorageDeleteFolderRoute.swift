//
//  StorageDeleteFolderRoute.swift
//  DigiMeSDK
//
//  Created on 23/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

struct StorageDeleteFolderRoute: Route {
    typealias ResponseType = Void

    static let method = "DELETE"
    static let path = "clouds"

    var pathParameters: [String] {
        return [storageId, "files/apps", applicationId, formatedPath]
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
    let storageId: String
    let applicationId: String
    let formatedPath: String
}
