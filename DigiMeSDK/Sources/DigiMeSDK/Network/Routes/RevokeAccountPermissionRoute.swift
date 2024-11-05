//
//  RevokeAccountPermissionRoute.swift
//  DigiMeSDK
//
//  Created on 17/01/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

struct RevokeAccountPermissionRoute: Route {
    typealias ResponseType = RevokeAccountPermissionResponse

    static let method = "GET"
    static let path = "permission-access/revoke/h:accountId"
    static let version: APIVersion = .public
    
    var customHeaders: [String: String] {
        [
            "Authorization": "Bearer " + jwt,
            "accountId": accountId,
            "redirectUri": redirectUri,
        ]
    }

    let jwt: String
    let accountId: String
    let redirectUri: String
}
