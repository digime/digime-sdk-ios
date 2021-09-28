//
//  Credentials.swift
//  DigiMeSDK
//
//  Created on 18/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Credentials for accessing user's digi.me library
public struct Credentials: Codable {
    let token: OAuthToken
    let writeAccessInfo: WriteAccessInfo?
}
