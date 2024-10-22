//
//  StorageListFilesRoute.swift
//  DigiMeSDK
//
//  Created on 10/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct StorageListFilesRoute: Route {
    typealias ResponseType = StorageFileList

    static let method = "GET"
    static let path = "clouds"

    var pathParameters: [String] {
        return [storageId, "files/apps", applicationId, formatedPath, "/"].compactMap { $0 }
    }

    var queryParameters: [URLQueryItem] {
        return [URLQueryItem(name: "recursive", value: String(recursive))]
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
    let storageId: String
    let applicationId: String
    let formatedPath: String?
    let recursive: Bool
}
