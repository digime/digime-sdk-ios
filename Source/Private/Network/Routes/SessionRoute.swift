//
//  SessionRoute.swift
//  DigiMeSDK
//
//  Created on 10/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct SessionRoute: Route {
    typealias ResponseType = Session
    
    static let method = "POST"
    static let path = "permission-access/session"
    
    var requestBody: RequestBody? {
        let body = SessionBody(appId: appId, contractId: contractId)
        return try? JSONRequestBody(parameters: body)
    }
    
    private struct SessionBody: Encodable {
        let agent = APIConfig.agent
        let accept = ReadAccept.gzipCompression
        let appId: String
        let contractId: String
        
        init(appId: String, contractId: String) {
            self.appId = appId
            self.contractId = contractId
        }
    }
        
    let appId: String
    let contractId: String
}
