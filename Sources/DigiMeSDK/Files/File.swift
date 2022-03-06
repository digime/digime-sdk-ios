//
//  File.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

/// Represents a file retrieved from library
public struct File: Codable {
    
    /// The identifier of the file
    public let identifier: String
    
    /// The file's metadata
    public let metadata: FileMetadata
    
    /// The file's raw data
    public let data: Data
    
    /// The file's raw data
    public let updatedDate: Date
    
    /// The file's MIME type
    public var mimeType: MimeType {
        switch metadata {
        case .mapped:
            return .applicationOctetStream
        case .raw(let meta):
            return meta.mimeType
        case .none:
            return .applicationOctetStream
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case metadata
        case data
        case updatedDate
        case mimeType
    }
    
    /// Convenience function to return data as JSON object, if possible
    /// - Returns: JSON object or nil if deserialization unsuccesful
    @discardableResult
    public func toJSON(persistResult: Bool = false) -> Any? {
        guard mimeType == .applicationJson || mimeType == .applicationOctetStream else {
            return nil
        }
        
        let result = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if
            persistResult,
            let result = result as? [[String: Any]] {
            
            FilePersistentStorage(with: .documentDirectory).store(object: result, fileName: identifier)
        }
        
        return result
    }
    
    /// Convenience function to return data as UIImage, if possible
    /// - Returns: UIImage or nil if mime type is not an image type
    public func toImage() -> UIImage? {
        let imageMimeTypes: [MimeType] = [.imageBmp, .imageGif, .imagePng, .imageJpeg, .imageTiff]
        guard imageMimeTypes.contains(mimeType) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    init(fileWithId id: String, rawData: Data, metadata: FileMetadata, updated: Date) {
        identifier = id
        data = rawData
        updatedDate = updated
        self.metadata = metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        metadata = try container.decode(FileMetadata.self, forKey: .metadata)
        data = try container.decode(Data.self, forKey: .data)
        updatedDate = try container.decode(Date.self, forKey: .updatedDate)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(mimeType, forKey: .mimeType)
    }
}
