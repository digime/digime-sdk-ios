//
//  TokenExchangeRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct TokenExchangeRoute: Route {
    typealias ResponseType = AuthResponse
    
    static let method = "POST"
    static let path = "oauth/token"
    static let version: APIVersion = .public
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    let jwt: String
}
