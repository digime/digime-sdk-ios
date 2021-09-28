//
//  ConsentResponse.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ConsentResponse {
    let authorizationCode: String
    let status: String
    let writeAccessInfo: WriteAccessInfo? // For write request authorization only
    
    init(code: String, status: String, writeAccessInfo: WriteAccessInfo? = nil) {
        self.authorizationCode = code
        self.status = status
        self.writeAccessInfo = writeAccessInfo
    }
}
