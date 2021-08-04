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

/// Metadata describing file contents
public enum FileMetadata {
    /// Metadata for a file with mapped service data
    case mapped(_ metadata: MappedFileMetadata)
    
    /// Metadata for a file which had been written
    case raw(_ metadata: RawFileMetadata)
    
    /// No metdata available
    case none
}

/// Metadata for a file with mapped service data
public struct MappedFileMetadata: Decodable {
    public let objectCount: Int
    public let objectType: String
    public let serviceGroup: String
    public let serviceName: String
}

/// Metadata for a file with raw data (typically one which has been written to library)
public struct RawFileMetadata: Codable {
    
    public struct Account: Codable, ExpressibleByStringLiteral {
        public let accountId: String
        
        enum DecodingKeys: String, CodingKey {
            case accountId = "accountid"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DecodingKeys.self)
            accountId = try container.decode(String.self, forKey: .accountId)
        }
        
        public init(stringLiteral value: String) {
            accountId = value
        }
    }
    
    public struct ObjectType: Codable {
        public let name: String
        public let references: [String]?
        
        public init(name: String, references: [String]? = nil) {
            self.name = name
            self.references = references
        }
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
    let providerName: String?
    
    enum DecodingKeys: String, CodingKey {
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
        case providerName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        mimeType = try container.decode(MimeType.self, forKey: .mimeType)
        accounts = try container.decode([Account].self, forKey: .accounts)
        reference = try container.decodeIfPresent([String].self, forKey: .reference)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        contractId = try container.decodeIfPresent(String.self, forKey: .contractId)
        appId = try container.decodeIfPresent(String.self, forKey: .appId)
        created = try container.decodeIfPresent(Double.self, forKey: .created)
        objectTypes = try container.decodeIfPresent([ObjectType].self, forKey: .objectTypes)
        serviceGroups = try container.decodeIfPresent([Int].self, forKey: .serviceGroups)
        partnerId = try container.decodeIfPresent(String.self, forKey: .partnerId)
        providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
    }
    
    public init(builder: RawFileMetadataBuilder) {
        mimeType = builder.mimeType
        accounts = builder.accounts.map { .init(stringLiteral: $0) }
        reference = builder.reference
        tags = builder.tags
        contractId = builder.contractId
        appId = builder.appId
        objectTypes = builder.objectTypes
        serviceGroups = builder.serviceGroups
        providerName = builder.providerName
        partnerId = nil
        created = nil
    }
}

public final class RawFileMetadataBuilder {
    let mimeType: MimeType
    let accounts: [String]
    private(set) var reference: [String]?
    private(set) var tags: [String]?
    private(set) var contractId: String?
    private(set) var appId: String?
    private(set) var objectTypes: [RawFileMetadata.ObjectType]?
    private(set) var serviceGroups: [Int]?
    private(set) var providerName: String?
    
    public init(mimeType: MimeType, accounts: [String]) {
        self.mimeType = mimeType
        self.accounts = accounts
    }
    
    public func reference(_ value: [String]) -> RawFileMetadataBuilder {
        reference = value
        return self
    }
    
    public func tags(_ value: [String]) -> RawFileMetadataBuilder {
        tags = value
        return self
    }
    
    public func contractId(_ value: String) -> RawFileMetadataBuilder {
        contractId = value
        return self
    }
    
    public func appId(_ value: String) -> RawFileMetadataBuilder {
        appId = value
        return self
    }
    
    public func providerName(_ value: String) -> RawFileMetadataBuilder {
        providerName = value
        return self
    }
    
    public func objectTypes(_ value: [RawFileMetadata.ObjectType]) -> RawFileMetadataBuilder {
        objectTypes = value
        return self
    }
    
    public func serviceGroups(_ value: [Int]) -> RawFileMetadataBuilder {
        serviceGroups = value
        return self
    }
    
    public func build() -> RawFileMetadata {
        RawFileMetadata(builder: self)
    }
}
