//
//  ServicesRoute.swift
//  DigiMeSDK
//
//  Created on 02/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ServicesRoute: Route {
    typealias ResponseType = ServicesResponse
    
    static let method = "GET"
    static let path = "discovery/services"
    static let version: APIVersion = .public
    
    var queryParameters: [URLQueryItem] {
        return [URLQueryItem(name: "includeSampleDataOnlySources", value: "true")]
    }
    
    var customHeaders: [String: String] {
        if let contractId = contractId {
            return ["contractId": contractId]
        }
        
        return [:]
    }
        
    let contractId: String?
}
