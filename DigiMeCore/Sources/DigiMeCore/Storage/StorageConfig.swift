//
//  Storage.swift
//  DigiMeCore
//
//  Created on 09/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct StorageConfig: Codable {
    public var cloudId: String
    public var accociatedKeyId: String

    enum CodingKeys: String, CodingKey {
        case cloudId = "id"
        case accociatedKeyId = "kid"
    }
}
