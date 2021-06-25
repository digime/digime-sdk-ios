//
//  ReadDataRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ReadDataRoute: Route {
    typealias ResponseType = Data
    
    static let method = "GET"
    static let path = "permission-access/query"
    
    var pathParameters: [String] {
        var parameters = [sessionKey]
        if let fileId = fileId {
            parameters.append(fileId)
        }
        
        return parameters
    }
    
    var customHeaders: [String : String] {
        ["Accept": "application/octet-stream"]
    }
    
    let sessionKey: String
    let fileId: String?
}
