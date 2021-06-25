//
//  AuthorizeRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct AuthorizeRoute: Route {
    typealias ResponseType = PreAuthResponse
    
    static let method = "POST"
    static let path = "oauth/authorize"
    
    var requestBody: RequestBody? {
        guard let body = AuthorizeBody(agent: agent, options: readOptions) else {
            return nil
        }
        
        return try? JSONRequestBody(parameters: body)
    }
    
    var customHeaders: [String : String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    private struct AuthorizeBody: Encodable {
        struct Actions: Encodable {
            let pull: ReadOptions?
        }
        
        let actions: Actions?
        let agent: Agent?
        init?(agent: Agent?, options: ReadOptions?) {
            guard agent != nil || options != nil else {
                return nil
            }
            
            self.agent = agent
            self.actions = Actions(pull: options)
        }
    }
    
    let jwt: String
    let agent: Agent?
    let readOptions: ReadOptions?
}
