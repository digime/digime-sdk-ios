//
//  ReadDataRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ReadDataRoute: Route {
    typealias ResponseType = FileResponse
    
    static let method = "GET"
    static let path = "permission-access/query"
    
    var pathParameters: [String] {
        [sessionKey, fileId]
    }
    
    var customHeaders: [String: String] {
        ["Accept": "application/octet-stream",
		 "Authorization": "Bearer " + jwt]
    }
	
	let jwt: String
    let sessionKey: String
    let fileId: String
    
    // Throws SDKError or DecodingError
    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        guard
            let metadataBase64 = headers["x-metadata"] as? String,
            let metadataData = Data(base64URLEncoded: metadataBase64) else {
            throw SDKError.errorParsingHeadersMetadataInTheResponse
        }
        
        let fileInfo = try metadataData.decoded() as FileInfo
        return FileResponse(data: data, info: fileInfo)
    }
}
