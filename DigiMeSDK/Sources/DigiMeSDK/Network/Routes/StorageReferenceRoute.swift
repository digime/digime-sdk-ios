//
//  StorageReferenceRoute.swift
//  DigiMeSDK
//
//  Created on 17/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

struct StorageReferenceRoute: Route {
    typealias ResponseType = ReferenceResponse

    static var method = "POST"
    static var path = "reference"

    var requestBody: RequestBody? {
        let body = StorageReferenceBody(type: "cloudId", value: cloudId)
        return try? JSONRequestBody(parameters: body)
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    private struct StorageReferenceBody: Encodable {
        let type: String
        let value: String
    }

    let jwt: String
    let cloudId: String
}

