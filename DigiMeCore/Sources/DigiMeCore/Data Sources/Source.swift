//
//  Source.swift
//  DigiMeCore
//
//  Created on 08/05/2024.
//

import Foundation

/// Information about a service data source
public struct Source: Codable, Identifiable {
    public var id: Int
//    public var dynamic: Bool
//    public var onboardable: Bool
    public var name: String
//    public var providerId: Int?
//    public var publishedDate: String
    public var publishedStatus: SourcePublishedStatus
//    public var reference: String
    public var category: [ServiceGroupType]
//    public var country: [ServiceCountry]
//    public var platform: [Platform]
    public var service: SourceService
    public var type: [SourceType]
    public var resource: SourceResource
//    public var json: JSONDataRepresentation
//    public var address: [SourceAddress]?
//    public var authorisation: Authorisation?
//    public var serviceId: Int?
//    public var homepageURL: String?
    public var options: ReadOptions?

    /// The identifiers of the service group this service belongs to
    public var serviceGroupIds: [Int] {
        category.map { $0.id }
    }

    /// The identifiers of the countries this service belongs to
//    public var countryIds: [Int] {
//        country.map { $0.identifier }
//    }

    public var isAvailable: Bool {
        return publishedStatus == .approved && service.publishedStatus == .approved
    }

    public var sampleDataOnly: Bool {
        return service.publishedStatus == .sampledataonly
    }

//    public init(id: Int, dynamic: Bool, onboardable: Bool, name: String, providerId: Int? = nil, publishedDate: String, publishedStatus: SourcePublishedStatus, reference: String, category: [ServiceGroupType], country: [ServiceCountry], platform: [Platform], service: SourceService, type: [SourceType], resource: SourceResource, json: JSONDataRepresentation, address: [SourceAddress]? = nil, authorisation: Authorisation? = nil, serviceId: Int? = nil, homepageURL: String? = nil) {
//        self.id = id
//        self.dynamic = dynamic
//        self.onboardable = onboardable
//        self.name = name
//        self.providerId = providerId
//        self.publishedDate = publishedDate
//        self.publishedStatus = publishedStatus
//        self.reference = reference
//        self.category = category
//        self.country = country
//        self.platform = platform
//        self.service = service
//        self.type = type
//        self.resource = resource
//        self.json = json
//        self.address = address
//        self.authorisation = authorisation
//        self.serviceId = serviceId
//        self.homepageURL = homepageURL
//    }
}

extension Source: Equatable {
    public static func == (lhs: Source, rhs: Source) -> Bool {
        return lhs.id == rhs.id
    }
}
