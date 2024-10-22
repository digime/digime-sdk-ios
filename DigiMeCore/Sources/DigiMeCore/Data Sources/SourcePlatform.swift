//
//  SourcePlatform.swift
//  DigiMeCore
//
//  Created on 07/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.

import Foundation

public struct SourcePlatform: Codable {
    public let id: Int?
    public let json: JSONDataRepresentation?
    public let name: String?
    public let reference: String?
}
