//
//  StorageFileInfo.swift
//  DigiMeCore
//
//  Created on 10/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct StorageFileInfo: Codable {
    public var id: String
    public var name: String
    public var originalName: String
    public var originalPath: String
    public var path: String
}
