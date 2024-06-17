//
//  SourceRequestCriteria.swift
//  DigiMeCore
//
//  Created on 08/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct SourceAddress: Codable {
    public var city: String
    public var streetName: String
    public var streetNumber: String
    public var zipCode: String
}

public struct JSONDataRepresentation: Codable {
    public var authentication: Authentication?
    public var authorisation: Authorisation?
    public var sync: Sync?
    public var homepageURL: String?
    public var collect: ServiceCollect?
}

public enum ApiUrl: Codable {
    case single(String)
    case multiple([String: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let urlString = try? container.decode(String.self) {
            self = .single(urlString)
        }
        else if let urlsDictionary = try? container.decode([String: String].self) {
            self = .multiple(urlsDictionary)
        }
        else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected to decode either a String or a Dictionary<String, String>")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let urlString):
            try container.encode(urlString)
        case .multiple(let urlsDictionary):
            try container.encode(urlsDictionary)
        }
    }
}

public struct Authentication: Codable {
    public var apiUrl: ApiUrl?
    public var postSteps: PostSteps?
    public var scopeJoinChar: String?
    public var scopes: [String]?
    public var url: AuthURL?
    public var revokeURL: String?
}

public struct PostSteps: Codable {
    public var attachUserId: URLPath?
    public var mapAccountProfile: MapAccountProfile
}

public struct URLPath: Codable {
    public var url: String?
    public var path: String?
    public var hash: [String]?
}

public struct MapAccountProfile: Codable {
    public var headerAuthentication: Bool?
    public var host: String?
    public var parameters: [String: String]?
    public var url: String?
}

public struct AuthURL: Codable {
    public var authenticate: String?
    public var code: AuthCode?
    public var options: AuthURLOptions?
}

public struct AuthURLOptions: Codable {
    public var correlationIdHeader: String?
    public var encodeRedirectUri: Bool?
    public var requestIdHeader: String?
}

public struct AuthCode: Codable {
    public var additionalOptions: [String: String]?
    public var authViaHeader: Bool?
    public var host: String?
    public var path: String?
}

public struct Authorisation: Codable {
    public var mode: String
    public var reauthType: String
    public var type: String
}

public struct Sync: Codable {
    public var type: SyncType
    public var enabled: Bool?
}

public struct SyncType: Codable {
    public var options: [SyncOption]?
}

public enum SyncOption: String, Codable {
    case auto = "auto"
    case manual = "manual"
    case unknown = "unknown"

    // Mapping from integers to SyncOption cases for initialization
    private static let intToCaseMap: [Int: SyncOption] = [
        1: .auto,
        2: .manual
    ]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self = SyncOption(rawValue: stringValue) ?? .unknown
        } else if let intValue = try? container.decode(Int.self) {
            self = SyncOption.intToCaseMap[intValue] ?? .unknown
        } else {
            throw DecodingError.typeMismatch(SyncOption.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode String or Int for SyncOption"))
        }
    }

    // Encoding always as a string
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

public struct SourceService: Codable {
    public var id: Int
//    public var dynamic: Bool
//    public var json: JSONDataRepresentation
//    public var name: String
//    public var publishedDate: Date
    public var publishedStatus: SourcePublishedStatus
//    public var reference: String
//    public var serviceTypeId: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id, dynamic, json, name, publishedDate, publishedStatus, reference, serviceTypeId
//    }
//
//    // Custom decoder to handle the date parsing
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(Int.self, forKey: .id)
//        dynamic = try container.decode(Bool.self, forKey: .dynamic)
//        name = try container.decode(String.self, forKey: .name)
//        publishedStatus = try container.decode(SourcePublishedStatus.self, forKey: .publishedStatus)
//        reference = try container.decode(String.self, forKey: .reference)
//        serviceTypeId = try container.decode(Int.self, forKey: .serviceTypeId)
//
//        if let jsonString = try? container.decode(String.self, forKey: .json) {
//            if let jsonData = jsonString.data(using: .utf8) {
//                json = try JSONDecoder().decode(JSONDataRepresentation.self, from: jsonData)
//            }
//            else {
//                throw DecodingError.dataCorruptedError(forKey: .json, in: container, debugDescription: "Could not decode JSON string.")
//            }
//        }
//        else if let jsonDataRepresentation = try? container.decode(JSONDataRepresentation.self, forKey: .json) {
//            json = jsonDataRepresentation
//        }
//        else {
//            throw DecodingError.dataCorruptedError(forKey: .json, in: container, debugDescription: "JSON is neither a valid String nor a Dictionary")
//        }
//
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        let dateString = try container.decode(String.self, forKey: .publishedDate)
//        if let date = formatter.date(from: dateString) {
//            publishedDate = date
//        }
//        else {
//            throw DecodingError.dataCorruptedError(forKey: .publishedDate, in: container, debugDescription: "Date string does not match ISO 8601 format expected by formatter.")
//        }
//    }
//
//    public func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(dynamic, forKey: .dynamic)
//        try container.encode(json, forKey: .json)
//        try container.encode(name, forKey: .name)
//        try container.encode(publishedStatus, forKey: .publishedStatus)
//        try container.encode(reference, forKey: .reference)
//        try container.encode(serviceTypeId, forKey: .serviceTypeId)
//
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        let dateString = formatter.string(from: publishedDate)
//        try container.encode(dateString, forKey: .publishedDate)
//    }
}

public struct ServiceCollect: Codable {
    public var request: [Request]
    public var keys: [CollectKey]?
}

public struct Request: Codable {
    public var method: String
    public var url: String
    public var header: [String: String]
    public var query: [String: String]
    public var body: [String: String]
}

public struct CollectKey: Codable {
    public var key: String
}

public enum AuthorisationType: String, Codable {
    case saas, sdk, none
}

public enum SourcePublishedStatus: String, Codable {
    case approved, pending, deprecated, blocked, sampledataonly, unknown

    // Mapping from integers to SourcePublishedStatus cases for initialization
    private static let intToCaseMap: [Int: SourcePublishedStatus] = [
        1: .approved,
        2: .pending,
        3: .deprecated,
        4: .blocked,
        5: .sampledataonly
    ]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self = SourcePublishedStatus(rawValue: stringValue) ?? .unknown
        }
        else if let intValue = try? container.decode(Int.self) {
            self = SourcePublishedStatus.intToCaseMap[intValue] ?? .unknown
        }
        else {
            throw DecodingError.typeMismatch(SourcePublishedStatus.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode String or Int for SourcePublishedStatus"))
        }
    }

    // Encoding always as a string
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

public struct SourcesSearch: Codable {
    public var name: [String]?      // [\x20-\x7E]{1,100}$
    public var city: [String]?      // [\x20-\x7E]{1,100}$
    public var zipCode: [String]?   // [\x20-\x7E]{1,100}$

    enum CodingKeys: String, CodingKey {
        case name
        case city = "address.city"
        case zipCode = "address.zipCode"
    }

    public init(name: [String]? = nil, city: [String]? = nil, zipCode: [String]? = nil) {
        self.name = name
        self.city = city
        self.zipCode = zipCode
    }
}

public struct SourcesSort: Codable {
    public let name: SortOrder?

    public init(name: SortOrder? = nil) {
        self.name = name
    }
}

public enum SortOrder: String, Codable {
    case asc, desc
}

public enum SourceTypeFilter: Int, Codable {
    case pull = 1
    case push = 2
}

public struct SourceTypeRequestFilter: Codable {
    var id: [SourceTypeFilter]

    public init(_ types: [SourceTypeFilter]) {
        self.id = types
    }

    public enum CodingKeys: String, CodingKey {
        case id = "id"
    }
}

public struct SourceFilter: Codable {
    public var id: SourceRequestFilter?
    public var publishedStatus: [SourcePublishedStatus]?
    public var service: SourceRequestFilter?
    public var country: SourceRequestFilter?
    public var category: SourceRequestFilter?
    public var platform: SourceRequestFilter?
    public var type: SourceTypeRequestFilter?

    enum CodingKeys: String, CodingKey {
        case id, publishedStatus, service, country, category, platform, type
    }

    public init(id: SourceRequestFilter? = nil, publishedStatus: [SourcePublishedStatus]? = nil, service: SourceRequestFilter? = nil, country: SourceRequestFilter? = nil, category: SourceRequestFilter? = nil, platform: SourceRequestFilter? = nil, type: SourceTypeRequestFilter? = nil) {
        self.id = id
        self.publishedStatus = publishedStatus
        self.service = service
        self.country = country
        self.category = category
        self.platform = platform
        self.type = type
    }
}

public enum SourcesFieldList: String, Codable {
    case address = "address"
    case category = "category"
    case categoryTypeId = "category.categoryTypeId"
    case categoryId = "category.id"
    case categoryJson = "category.json"
    case categoryName = "category.name"
    case categoryReference = "category.reference"
    case country = "country"
    case countryCode = "country.code"
    case countryId = "country.id"
    case countryJson = "country.json"
    case countryName = "country.name"
    case dynamic = "dynamic"
    case id = "id"
    case json = "json"
    case onboardable = "onboardable"
    case name = "name"
    case platform = "platform"
    case platformId = "platform.id"
    case platformJson = "platform.json"
    case platformName = "platform.name"
    case platformReference = "platform.reference"
    case providerId = "providerId"
    case publishedDate = "publishedDate"
    case publishedStatus = "publishedStatus"
    case reference = "reference"
    case resourceUrl = "resource.url"
    case resourceMimetype = "resource.mimetype"
    case service = "service"
    case serviceDynamic = "service.dynamic"
    case serviceId = "service.id"
    case serviceJson = "service.json"
    case serviceName = "service.name"
    case servicePublishedDate = "service.publishedDate"
    case servicePublishedStatus = "service.publishedStatus"
    case serviceReference = "service.reference"
    case serviceServiceTypeId = "service.serviceTypeId"
    case type = "type"
    case typeId = "type.id"
    case typeName = "type.name"
    case typeReference = "type.reference"
}

public struct SourcesQuery: Codable {
    public var search: SourcesSearch?
    public var include: [SourcesFieldList]?
    public var filter: SourceFilter?

    public init(search: SourcesSearch? = nil, include: [SourcesFieldList]? = nil, filter: SourceFilter? = nil) {
        self.search = search
        self.include = include
        self.filter = filter
    }
}

public struct SourceRequestCriteria: Codable {
    public var limit: Int?
    public var offset: Int?
    public var sort: SourcesSort?
    public var query: SourcesQuery?

    public init(limit: Int? = nil, offset: Int? = nil, sort: SourcesSort? = nil, query: SourcesQuery? = nil) {
        self.limit = limit
        self.offset = offset
        self.sort = sort
        self.query = query
    }
}
