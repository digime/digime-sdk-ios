//
//  MappedFileMetadata.swift
//  DigiMeSDK
//
//  Created on 28/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Metadata for a file with mapped service data
public struct MappedFileMetadata: Codable {
    public let objectCount: Int
    public let objectType: String
    public let serviceGroup: String
    public let serviceName: String
}
