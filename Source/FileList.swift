//
//  FileList.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a list of files available from digi.me library
public struct FileList: Decodable, Equatable {
    
    /// The list of available files
    public let files: [FileListItem]?
    
    let status: SyncStatus
    
    enum CodingKeys: String, CodingKey {
        case files = "fileList"
        case status
    }
}
