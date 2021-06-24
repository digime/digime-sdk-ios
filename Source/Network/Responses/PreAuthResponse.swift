//
//  PreAuthResponse.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct PreAuthResponse: Decodable {
    let token: String
    let session: Session
}
