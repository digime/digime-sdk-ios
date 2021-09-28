//
//  FileMetadata.swift
//  DigiMeSDK
//
//  Created on 28/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Metadata describing file contents
public enum FileMetadata {
    /// Metadata for a file with mapped service data
    case mapped(_ metadata: MappedFileMetadata)
    
    /// Metadata for a file which had been written
    case raw(_ metadata: RawFileMetadata)
    
    /// No metdata available
    case none
}
