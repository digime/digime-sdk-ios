//
//  WriteDataRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct WriteDataRoute: Route {
    typealias ResponseType = SessionResponse
    
    static let method = "POST"
    static let path = "permission-access/postbox"
    
    var requestBody: RequestBody? {
        let body = MultipartFormRequestBody()
        body.setData { multipartFormData in
            multipartFormData.append(data: payload, name: "file", fileName: "file")
        }
        return body
    }
    
    var customHeaders: [String: String] {
        ["Authorization": "Bearer " + jwt]
    }
    
    var pathParameters: [String] {
        [postboxId]
    }
    
    let postboxId: String
    let payload: Data
    let jwt: String
}
