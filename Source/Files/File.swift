//
//  File.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a file retrieved from library
public struct File {
    
    /// The identifier of the file
    public let identifier: String
    
    /// The file's metadata
    public let metadata: FileMetadata
    
    /// The file's raw data
    public let data: Data
    
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
    
    /// Convenience function to return data as JSON object, if possible
    /// - Returns: JSON object or nil if deserialization unsuccesful
    public func toJSON() -> Any? {
        guard mimeType == .applicationJson else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: [])
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
    
    init(fileWithId id: String, rawData: Data, metadata: FileMetadata) {
        identifier = id
        data = rawData
        self.metadata = metadata
    }
}
