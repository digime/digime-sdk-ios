//
//  NetworkRouter.swift
//  DigiMeSDK
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum NetworkRouter {
    case authorize(jwt: String, agent: Agent?, readOptions: ReadOptions?)
    case tokenExchange(jwt: String)
    case trigger(jwt: String, agent: Agent?, readOptions: ReadOptions?)
    case read(sessionKey: String, fileId: String?)
    case write(postboxId: String, payload: Data, jwt: String)
    
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
    
    private var baseURLPath: String {
        switch self {
        default:
            return "https://api.digi.me/v1.6/"
        }
    }
    
    private var method: String {
        switch self {
        case .authorize, .tokenExchange, .trigger, .write:
            return "POST"
            
        case .read:
            return "GET"
        }
    }
    
    private var path: String {
        switch self {
        case .authorize:
            return "/oauth/authorize"
            
        case .tokenExchange:
            return "/oauth/token"
            
        case .trigger:
            return "/permission-access/trigger"
            
        case .read(let sessionKey, let fileId):
            var path = "/permission-access/query/\(sessionKey)"
            if let fileId = fileId {
                path += "/\(fileId)"
            }
            
            return path
            
        case .write(let postboxId, _, _):
            return "/permission-access/postbox/\(postboxId)"
        }
    }
    
    private var body: RequestBody? {
        switch self {
        case .tokenExchange, .read:
            return nil
            
        case .authorize(_, let agent, let readOptions):
            guard let body = AuthorizeBody(agent: agent, options: readOptions) else {
                return nil
            }
            
            return try? JSONRequestBody(parameters: body)
            
        case .trigger(_, let agent, let readOptions):
            guard let body = TriggerBody(agent: agent, options: readOptions) else {
                return nil
            }
            
            return try? JSONRequestBody(parameters: body)
            
        case .write(_, let data, _):
            let body = MultipartFormRequestBody()
            body.setData { multipartFormData in
                multipartFormData.append(data: data, name: "file", fileName: "file")
            }
            return body
        }
    }
    
    private var authorizationToken: String? {
        switch self {
        case .authorize(let token, _, _),
             .tokenExchange(let token),
             .trigger(let token, _, _),
             .write(_, _, let token):
            return token
            
        case .read:
            return nil
        }
    }
}

extension NetworkRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: baseURLPath)!

    
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method
        if let authorizationToken = authorizationToken {
            request.setValue("Bearer " + authorizationToken, forHTTPHeaderField: "Authorization")
        }

        
        if let body = body {
            request.httpBody = body.data
            body.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }
        
        return request
    }
}
