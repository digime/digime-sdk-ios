//
//  ConsentError.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum ConsentError: String, Error {
    case initializeCheckFailed = "INITIALIZE_CHECK_FAIL"
    case userCancelled = "USER_CANCEL"
    case serviceOnboardError = "ONBOARD_ERROR"
    case invalidCode = "INVALID_CODE"
    case serverError = "SERVER_ERROR"
    
    case unexpectedError
}
