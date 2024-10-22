//
//  FileListItem.swift
//  DigiMeCore
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents an available file from digi.me library
public struct FileListItem: Decodable, Equatable {
    /// The name of the available file
    public let name: String
    public let updatedDate: Date
    public let objectVersion: String?
    
    public init(name: String, updatedDate: Date, objectVersion: String? = nil) {
        self.name = name
        self.objectVersion = objectVersion
        self.updatedDate = updatedDate
    }
}
