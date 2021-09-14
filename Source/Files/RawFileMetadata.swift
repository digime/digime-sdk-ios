//
//  RawFileMetadata.swift
//  DigiMeSDK
//
//  Created on 28/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

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
