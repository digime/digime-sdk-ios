//
//  ErrorResponse.swift
//  DigiMeSDK
//
//  Created on 07/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable {
    struct Recovery: Decodable {
        let validAt: TimeInterval
    }
    
    let code: String
    let message: String
    let reference: String?
    let recovery: Recovery?
}
