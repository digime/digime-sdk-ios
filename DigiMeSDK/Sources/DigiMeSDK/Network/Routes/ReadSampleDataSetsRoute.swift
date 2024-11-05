//
//  ReadSampleDataSetsRoute.swift
//  DigiMeSDK
//
//  Created on 07/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct ReadSampleDataSetsRoute: Route {
    typealias ResponseType = [String: SampleDataset]
    
    static let method = "GET"
    static let path = "permission-access/sample/datasets"
    static let version: APIVersion = .public
    
    var pathParameters: [String] {
        [serviceId]
    }
    
    var customHeaders: [String: String] {
        ["Accept": "application/json",
         "Authorization": "Bearer " + jwt]
    }
    
    let jwt: String
    let serviceId: String
}
