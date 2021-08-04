//
//  File.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public enum DataParsingError: Error {
    case couldNotDeserialiseRawData
}

public protocol InitialisableFromRawData {
    init(rawData: Data, mimeType: MimeType) throws
}

public enum MimeType: String, CaseIterable, Codable {
    case applicationJson = "application/json"
    case applicationOctetStream = "application/octet-stream"
    
    case imageJpeg = "image/jpeg"
    case imageTiff = "image/tiff"
    case imagePng = "image/png"
    case imageGif = "image/gif"
    case imageBmp = "image/bmp"
    
    case textPlain = "text/plain"
    case textJson = "text/json"
}

public protocol DataRepresentation: InitialisableFromRawData {
    
    associatedtype FileDataType
    
    static var compatibleMimeTypes: [MimeType] { get }
    
    var fileMimeType: MimeType { get }
    var fileContent: FileDataType { get }
}

public class JSONData: DataRepresentation {
    public var fileMimeType: MimeType
    public var fileContent: [[AnyHashable: Any]]
    
    public static let compatibleMimeTypes: [MimeType] = [MimeType.applicationJson]
    
    public required init(rawData: Data, mimeType: MimeType) throws {
        
        guard let json = (try? JSONSerialization.jsonObject(with: rawData, options: [])) as? [[AnyHashable: Any]] else {
            throw DataParsingError.couldNotDeserialiseRawData
        }
        
        self.fileContent = json
        self.fileMimeType = mimeType
    }
}

public class ImageData: DataRepresentation {
    public var fileMimeType: MimeType
    public var fileContent: UIImage
    
    public static let compatibleMimeTypes: [MimeType] = [.imageBmp, .imageGif, .imagePng, .imageJpeg, .imageTiff]
    
    public required init(rawData: Data, mimeType: MimeType) throws {
        
        guard let image = UIImage(data: rawData) else {
            throw DataParsingError.couldNotDeserialiseRawData
        }
        
        self.fileContent = image
        self.fileMimeType = mimeType
    }
}

public class RawData: DataRepresentation {
    public var fileMimeType: MimeType
    public var fileContent: Data
    
    public static let compatibleMimeTypes: [MimeType] = MimeType.allCases
    
    public required init(rawData: Data, mimeType: MimeType) throws {
        self.fileContent = rawData
        self.fileMimeType = mimeType
    }
}

public class FileContainer<DataType: DataRepresentation> {
    
    private var file: DataType
    
    public var identifier: String
    public var metadata: FileMetadata
    
    public var content: DataType.FileDataType {
        return file.fileContent
    }
    
    init(emptyFileWithId id: String, dataType: DataType.Type, metadata: FileMetadata) throws {
        identifier = id
        file = try dataType.init(rawData: Data(), mimeType: MimeType.applicationOctetStream)
        self.metadata = metadata
    }
    
    init(fileWithId id: String, rawData: Data, mimeType: MimeType, dataType: DataType.Type, metadata: FileMetadata) throws {
        identifier = id
        file = try dataType.init(rawData: rawData, mimeType: mimeType)
        self.metadata = metadata
    }
}
