//
//  FileInfo.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct FileInfo: Decodable {
    let compression: String?
    let metadata: FileMetadata
    
    enum CodingKeys: String, CodingKey {
        case compression
        case metadata
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        compression = try container.decodeIfPresent(String.self, forKey: .compression)

        if container.contains(.metadata) {
            if let mappedMetadata = try? container.decode(MappedFileMetadata.self, forKey: .metadata) {
                metadata = .mapped(mappedMetadata)
            }
            else if let rawMetadata = try? container.decode(RawFileMetadata.self, forKey: .metadata) {
                metadata = .raw(rawMetadata)
            }
            else {
                throw DecodingError.typeMismatch(FileMetadata.self, .init(codingPath: [CodingKeys.metadata], debugDescription: "Unable to decode metadata for either raw file or mapped file."))
            }
        }
        else {
            metadata = FileMetadata.none
        }
    }
}
