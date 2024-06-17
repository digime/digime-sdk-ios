//
//  CategoriesRoute.swift
//  DigiMeSDK
//
//  Created on 24/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct CategoriesRoute: Route {
    typealias ResponseType = CategoriesResponse

    static let method = "POST"
    static let path = "discovery/categories"

    var requestBody: RequestBody? {
        return try? JSONRequestBody(parameters: payload)
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
    let payload: SourceCategoriesRequestCriteria
}
