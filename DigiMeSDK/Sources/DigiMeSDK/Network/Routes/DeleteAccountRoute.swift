//
//  DeleteAccountRoute.swift
//  DigiMeSDK
//
//  Created on 04/01/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.

import Foundation

struct DeleteAccountRoute: Route {
    typealias ResponseType = Void

    static let method = "DELETE"
    static let path = "permission-access/service/h:accountId"
    static let version: APIVersion = .public
    
    var customHeaders: [String: String] {
        [
            "Authorization": "Bearer " + jwt,
            "accountId": accountId,
        ]
    }

    let jwt: String
    let accountId: String
}
