//
//  StorageFileList.swift
//  DigiMeCore
//
//  Created on 10/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct StorageFileList: Codable {
    public var files: [StorageFileInfo]?
    public var total: Int
}
