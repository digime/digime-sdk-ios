//
//  StorageUploadFileRoute.swift
//  DigiMeSDK
//
//  Created on 10/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct StorageUploadFileRoute: Route {
    typealias ResponseType = StorageUploadFileInfo

    static let method = "POST"
    static let path = "clouds"

    var pathParameters: [String] {
        return [storageId, "files/apps", applicationId, formatedPath, fileName].compactMap { $0 }
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt,
         "contentType": "multipart/form-data"]
    }
    
    let jwt: String
    let storageId: String
    let applicationId: String
    let fileName: String
    let formatedPath: String?
}

