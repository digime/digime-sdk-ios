//
//  PushDataToProviderRoute.swift
//  DigiMeSDK
//
//  Created on 13/07/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

struct PushDataToProviderRoute: Route {
    typealias ResponseType = Data
    
    static let method = "POST"
    static let path = "permission-access/import/h:accountId"
    static let version: APIVersion = .public
    
    var requestBody: RequestBody? {
       return FilePushBody(data: payload)
    }
    
    var customHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer " + jwt,
            "accountId": accountId,
        ]
    }

    var pathParameters: [String] {
        return [standard, version]
    }
    
    private struct FilePushBody: RequestBody {
        var headers: [String: String] {
            [:]
        }
        
        var data: Data
    }
    
    let jwt: String
    let accountId: String
    let standard: String
    let version: String
    let payload: Data
}
