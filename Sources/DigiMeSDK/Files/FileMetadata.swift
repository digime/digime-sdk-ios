//
//  FileMetadata.swift
//  DigiMeSDK
//
//  Created on 28/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Metadata describing file contents
public enum FileMetadata: Codable {
    
    /// Metadata for a file with mapped service data
    case mapped(_ metadata: MappedFileMetadata)
    
    /// Metadata for a file which had been written
    case raw(_ metadata: RawFileMetadata)
    
    /// No metdata available
    case none
}

extension FileMetadata {

    private enum CodingKeys: String, CodingKey {
        case mapped
        case raw
        case none
    }

    enum FileMetadataCodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(MappedFileMetadata.self, forKey: .mapped) {
            self = .mapped(value)
            return
        }
        
        if let value = try? values.decode(RawFileMetadata.self, forKey: .raw) {
            self = .raw(value)
            return
        }
        
        throw FileMetadataCodingError.decoding("Whoops! \(dump(values))")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .mapped(let metadata):
            try container.encode(metadata, forKey: .mapped)
        case .raw(let metadata):
            try container.encode(metadata, forKey: .raw)
        case .none:
            try container.encode(FileMetadata.`none`, forKey: .none)
        }
    }
}
