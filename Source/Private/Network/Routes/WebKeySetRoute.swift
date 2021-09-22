//
//  WebKeySetRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct WebKeySetRoute: Route {
    typealias ResponseType = JSONWebKeySet
    
    static let method = "GET"
    static let path = "jwks/oauth"
}
