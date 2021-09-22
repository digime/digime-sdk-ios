//
//  TokenReferenceRoute.swift
//  DigiMeSDK
//
//  Created on 01/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct TokenReferenceRoute: Route {
    typealias ResponseType = TokenSessionResponse
    
    static let method = "POST"
    static let path = "oauth/token/reference"
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    let jwt: String
}
