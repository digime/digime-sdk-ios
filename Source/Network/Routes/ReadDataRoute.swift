//
//  ReadDataRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ReadDataRoute: Route {
    typealias ResponseType = (Data, FileInfo)
    
    static let method = "GET"
    static let path = "permission-access/query"
    
    var pathParameters: [String] {
        var parameters = [sessionKey]
        if let fileId = fileId {
            parameters.append(fileId)
        }
        
        return parameters
    }
    
    var customHeaders: [String: String] {
        ["Accept": "application/octet-stream"]
    }
    
    let sessionKey: String
    let fileId: String?

    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        guard
            let metadataBase64 = headers["X-Metadata"] as? String,
            let metadataData = Data(base64URLEncoded: metadataBase64) else {
            throw SDKError.invalidData
        }
        
        let fileInfo = try metadataData.decoded() as FileInfo
        return (data, fileInfo)
    }
}

struct FileInfo: Decodable {
    let compression: String?
    let metadata: FileMetadata?
}

struct FileMetadata: Decodable {
    let objectCount: Int
    let objectType: String
    let serviceGroup: String
    let serviceName: String
}
