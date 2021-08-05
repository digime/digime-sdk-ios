//
//  SyncError.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct SyncError: Decodable, Equatable {
    let code: String
    let statusCode: Int
    let message: String
}
