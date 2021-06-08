//
//  OAuthToken.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct OAuthToken {
    let accessToken: String
    let refreshToken: String
    let expiry: Date
    let tokenType: String?
}
