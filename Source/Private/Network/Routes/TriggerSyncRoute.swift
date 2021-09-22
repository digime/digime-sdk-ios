//
//  TriggerSyncRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct TriggerSyncRoute: Route {
    typealias ResponseType = SessionResponse
    
    static let method = "POST"
    static let path = "permission-access/trigger"
    
    var requestBody: RequestBody? {
        let body = TriggerBody(options: readOptions)
        return try? JSONRequestBody(parameters: body)
    }
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    private struct TriggerBody: Encodable {
        let agent = APIConfig.agent
        let limits: Limits?
        let scope: Scope?
        let accept = ReadAccept.gzipCompression
        
        init(options: ReadOptions?) {
            self.limits = options?.limits
            self.scope = options?.scope
        }
    }
    
    let jwt: String
    let readOptions: ReadOptions?
}
