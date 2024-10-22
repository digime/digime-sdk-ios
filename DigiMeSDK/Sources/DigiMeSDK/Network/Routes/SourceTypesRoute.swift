//
//  SourceTypesRoute.swift
//  DigiMeSDK
//
//  Created on 24/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct SourceTypesRoute: Route {
    typealias ResponseType = SourceTypesResponse

    static let method = "POST"
    static let path = "discovery/sourceTypes"

    var requestBody: RequestBody? {
        return try? JSONRequestBody(parameters: payload)
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
    let payload: SourceTypesRequestCriteria
}
