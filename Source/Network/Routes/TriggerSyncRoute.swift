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
        guard let body = TriggerBody(agent: agent, options: readOptions) else {
            return nil
        }
        
        return try? JSONRequestBody(parameters: body)
    }
    
    var customHeaders: [String : String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    private struct TriggerBody: Encodable {
        let agent: Agent?
        let limits: Limits?
        let scope: Scope?
        let accept: ReadAccept?
        
        init?(agent: Agent?, options: ReadOptions?) {
            guard agent != nil || options != nil else {
                return nil
            }
            
            self.agent = agent
            self.limits = options?.limits
            self.scope = options?.scope
            self.accept = options?.accept
        }
    }
    
    let jwt: String
    let agent: Agent?
    let readOptions: ReadOptions?
}
