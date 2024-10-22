//
//  ConsentResponse.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct ConsentResponse {
    let authorizationCode: String
    let status: String
    let accountReference: String?
    let writeAccessInfo: WriteAccessInfo? // For write request authorization only
    
    init(code: String, status: String, accountReference: String?, writeAccessInfo: WriteAccessInfo? = nil) {
        self.authorizationCode = code
        self.status = status
        self.accountReference = accountReference
        self.writeAccessInfo = writeAccessInfo
    }
}
