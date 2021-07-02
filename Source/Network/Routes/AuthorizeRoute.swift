//
//  AuthorizeRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct AuthorizeRoute: Route {
    typealias ResponseType = TokenSessionResponse
    
    static let method = "POST"
    static let path = "oauth/authorize"
    
    var requestBody: RequestBody? {
        let body = AuthorizeBody(options: readOptions)
        return try? JSONRequestBody(parameters: body)
    }
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    private struct AuthorizeBody: Encodable {
        struct Actions: Encodable {
            let pull: PullOptions
        }
        
        struct PullOptions: Encodable {
            let limits: Limits?
            let scope: Scope?
            let accept = ReadAccept.gzipCompression
            
            init(readOptions: ReadOptions?) {
                self.limits = readOptions?.limits
                self.scope = readOptions?.scope
            }
        }
        
        let actions: Actions?
        let agent = APIConfig.agent
        
        init(options: ReadOptions?) {
            self.actions = Actions(pull: PullOptions(readOptions: options))
        }
    }
    
    let jwt: String
    let readOptions: ReadOptions?
}
