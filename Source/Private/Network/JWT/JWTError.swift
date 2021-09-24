//
//  JWTError.swift
//  DigiMeSDK
//
//  Created on 22/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum JWTError: Error {
    case invalidJWTString
    case invalidPrivateKey
    case failedVerification
}
