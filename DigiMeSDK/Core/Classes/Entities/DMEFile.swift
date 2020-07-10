//
//  DMEFile.swift
//  DigiMeSDK
//
//  Created on 16/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

public enum DMEDataParsingError: Error {
    case couldNotDeserialiseRawData
}

public protocol DMEInitialisableFromRawData {
    init(rawData: Data, mimeType: DMEMimeType) throws
}

@objc
public enum DMEMimeType: Int, CaseIterable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        switch value {
        case "image/jpeg": self = .image_jpeg
        case "image/tiff": self = .image_tiff
        case "image/png": self = .image_png
        case "image/gif": self = .image_gif
        case "image/bmp": self = .image_bmp
        case "text/plain": self = .text_plain
        case "text/json": self = .text_json
        case "application/json": self = .application_json
        case "application/octet-stream": self = .application_octetStream // Line not strictly required, but present for clarity.
        default: self = .application_octetStream
        }
    }
    
    case application_json
    case application_octetStream
    
    case image_jpeg
    case image_tiff
    case image_png
    case image_gif
    case image_bmp
    
    case text_plain
    case text_json
}

internal protocol DMEDataRepresentation: DMEInitialisableFromRawData {
    
    associatedtype FileDataType
    
    static var compatibleMimeTypes: [DMEMimeType] { get }
    
    var fileMimeType: DMEMimeType { get }
    var fileContent: FileDataType { get }
}

internal class DMEJSONData: DMEDataRepresentation {
    
    public typealias FileDataType = [[AnyHashable: Any]]
    public var fileMimeType: DMEMimeType
    public var fileContent: FileDataType
    
    public static let compatibleMimeTypes: [DMEMimeType] = [DMEMimeType.application_json]
    
    public required init(rawData: Data, mimeType: DMEMimeType) throws {
        
        guard let json = (try? JSONSerialization.jsonObject(with: rawData, options: [])) as? [[AnyHashable: Any]] else {
            throw DMEDataParsingError.couldNotDeserialiseRawData
        }
        
        self.fileContent = json
        self.fileMimeType = mimeType
    }
}

internal class DMEImageData: DMEDataRepresentation {
    
    public typealias FileDataType = UIImage
    public var fileMimeType: DMEMimeType
    public var fileContent: FileDataType
    
    public static let compatibleMimeTypes: [DMEMimeType] = [.image_bmp, .image_gif, .image_png, .image_jpeg, .image_tiff]
    
    public required init(rawData: Data, mimeType: DMEMimeType) throws {
        
        guard let image = UIImage(data: rawData) else {
            throw DMEDataParsingError.couldNotDeserialiseRawData
        }
        
        self.fileContent = image
        self.fileMimeType = mimeType
    }
}

// DMERawData doubles as the ObjC compatibility layer, and hence exposes
// a number of 'try and do something' methods.

@objcMembers
internal class DMERawData: NSObject, DMEDataRepresentation {
    
    public typealias FileDataType = Data
    public var fileMimeType: DMEMimeType
    public var fileContent: FileDataType
    
    public static let compatibleMimeTypes: [DMEMimeType] = DMEMimeType.allCases
    
    public required init(rawData: Data, mimeType: DMEMimeType) throws {
        self.fileContent = rawData
        self.fileMimeType = mimeType
    }
}

// @available(swift, obsoleted: 0.1, message: "Usage of DMEFile is limited to Objective-C. For Swift, which supports generics, use DMEFileContainer.")
@objcMembers
public class DMEFile: NSObject {
    
    private var boxedFile: DMERawData
    public var fileId: String
    public var fileMetadata: DMEFileMetadata?
    
    public var fileMimeType: DMEMimeType {
        return fileMetadata?.mimeType ?? .application_octetStream
    }
    public var fileContent: Data {
        return boxedFile.fileContent
    }
    
    @available(*, deprecated, message: "Please use -[DMEFile fileContentAsJSON] instead.")
    @available(*, renamed: "fileContentAsJSON")
    public var json: [[AnyHashable: Any]]? {
        return fileContentAsJSON()
    }
    
    public override var description: String {
        let objCount = fileContentAsJSON()?.count ?? -1
        return "File ID: \(fileId), \(objCount >= 0 ? "\(objCount) objects." : "\(fileContent.count) bytes.")"
    }
    
    public init(fileId: String, fileContent: Data, fileMetadata: DMEFileMetadata?) {
        self.fileId = fileId
        self.boxedFile = try! DMERawData(rawData: fileContent, mimeType: fileMetadata?.mimeType ?? .application_octetStream)
        self.fileMetadata = fileMetadata
    }
    
    public func fileContentAsJSON() -> [[AnyHashable: Any]]? {
        return (try? JSONSerialization.jsonObject(with: fileContent, options: [])) as? [[AnyHashable: Any]]
    }
    
    public func fileContentAsImage() -> UIImage? {
        return UIImage(data: fileContent)
    }
    
    public func fileContentAsString() -> String? {
        return String(data: fileContent, encoding: .utf8)
    }
}

internal class DMEFileContainer<DataType: DMEDataRepresentation> {
    
    public var fileId: String
    private var file: DataType
    public var fileContent: DataType.FileDataType {
        return file.fileContent
    }
    
    public init(emptyFileWithId id: String, andDataType dataType: DataType.Type) {
        fileId = id
        file = try! dataType.init(rawData: Data(), mimeType: DMEMimeType.application_octetStream)
    }
    
    public init(fileWithId id: String, rawData: Data, mimeType: DMEMimeType, as dataType: DataType.Type) throws {
        fileId = id
        file = try dataType.init(rawData: rawData, mimeType: mimeType)
    }
}
