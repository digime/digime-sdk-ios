//
//  FileListRoute.swift
//  DigiMeSDK
//
//  Created on 29/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct FileListRoute: Route {
    typealias ResponseType = FileList
    
    static let method = "GET"
    static let path = "permission-access/query"
    
    var pathParameters: [String] {
        [sessionKey]
    }
    
	var customHeaders: [String: String] {
		["Authorization": "Bearer " + jwt]
	}
	
	let jwt: String
    let sessionKey: String
    
    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        return try data.decoded(dateDecodingStrategy: .millisecondsSince1970) as ResponseType
    }
}
