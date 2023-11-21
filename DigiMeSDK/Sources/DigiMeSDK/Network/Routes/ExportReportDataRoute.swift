//
//  ExportReportDataRoute.swift
//  DigiMeSDK
//
//  Created on 25/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

struct ExportReportDataRoute: Route {
    typealias ResponseType = Data
    
    static let method = "GET"
    static let path = "export"
    
    var customHeaders: [String: String] {
        ["Accept": "application/octet-stream",
         "Authorization": "Bearer " + jwt]
    }
    
    var queryParameters: [URLQueryItem] {
        return [URLQueryItem(name: "format", value: format),
                URLQueryItem(name: "from", value: String(from)),
                URLQueryItem(name: "to", value: String(to))]
    }
    
    var pathParameters: [String] {
        [serviceTypeName, "report"]
    }
    
    let jwt: String
    let serviceTypeName: String
    let format: String
    let from: TimeInterval
    let to: TimeInterval
}
