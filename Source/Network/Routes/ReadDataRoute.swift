//
//  ReadDataRoute.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct ReadDataRoute: Route {
    typealias ResponseType = (Data, FileInfo)
    
    static let method = "GET"
    static let path = "permission-access/query"
    
    var pathParameters: [String] {
        [sessionKey, fileId]
    }
    
    var customHeaders: [String: String] {
        ["Accept": "application/octet-stream"]
    }
    
    let sessionKey: String
    let fileId: String

    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        guard
            let metadataBase64 = headers["X-Metadata"] as? String,
            let metadataData = Data(base64URLEncoded: metadataBase64) else {
            throw SDKError.invalidData
        }
        
        let fileInfo = try metadataData.decoded() as FileInfo
        return (data, fileInfo)
    }
}

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
}

public enum FileMetadata {
    case mapped(_ metadata: MappedFileMetadata)
    case raw(_ metadata: RawFileMetadata)
}

public struct MappedFileMetadata: Decodable {
    public let objectCount: Int
    public let objectType: String
    public let serviceGroup: String
    public let serviceName: String
}

public struct RawFileMetadata: Decodable {
    public struct Account: Decodable {
        public let accountId: String
        
        enum CodingKeys: String, CodingKey {
            case accountId = "accountid"
        }
    }
    
    public struct ObjectType: Decodable {
        public let name: String
        public let references: [String]?
    }
    
    public let mimeType: MimeType
    public let accounts: [Account]
    public let reference: [String]?
    public let tags: [String]?
    public let contractId: String?
    public let created: Double?
    public let appId: String?
    public let objectTypes: [ObjectType]?
    public let serviceGroups: [Int]?
    public let partnerId: String?
    
    enum CodingKeys: String, CodingKey {
        case mimeType = "mimetype"
        case accounts
        case reference
        case tags
        case contractId = "contractid"
        case created
        case appId = "appid"
        case objectTypes = "objecttypes"
        case serviceGroups = "servicegroups"
        case partnerId = "partnerid"
    }
}
