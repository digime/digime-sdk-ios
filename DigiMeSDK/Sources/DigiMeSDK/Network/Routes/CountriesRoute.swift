//
//  CountriesRoute.swift
//  DigiMeSDK
//
//  Created on 24/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct CountriesRoute: Route {
    typealias ResponseType = SourceCountriesResponse

    static let method = "POST"
    static let path = "discovery/countries"

    var requestBody: RequestBody? {
        return try? JSONRequestBody(parameters: payload)
    }

    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }

    let jwt: String
    let payload: SourceCountriesRequestCriteria
}
