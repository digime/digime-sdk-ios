//
//  ConnectedAccountsRoute.swift
//  DigiMeSDK
//
//  Created on 12/07/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct ConnectedAccountsRoute: Route {
    typealias ResponseType = [SourceAccountData]
    
    static let method = "GET"
    static let path = "permission-access/accounts"
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    let jwt: String
}
