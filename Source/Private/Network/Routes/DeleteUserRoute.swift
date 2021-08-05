//
//  DeleteUserRoute.swift
//  DigiMeSDK
//
//  Created on 01/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct DeleteUserRoute: Route {
    typealias ResponseType = Void
    
    static let method = "DELETE"
    static let path = "user"
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    let jwt: String
}
