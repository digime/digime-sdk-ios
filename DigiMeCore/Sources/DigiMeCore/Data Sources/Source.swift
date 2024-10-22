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
    public var name: String
    public var publishedStatus: SourcePublishedStatus
    public var category: [ServiceGroupType]
    public var service: SourceService
    public var type: [SourceType]
    public var resource: SourceResource
    public var options: ReadOptions?

    /// The identifiers of the service group this service belongs to
    public var serviceGroupIds: [Int] {
        category.map { $0.id }
    }

    public var isAvailable: Bool {
        return publishedStatus == .approved && service.publishedStatus == .approved
    }

    public var sampleDataOnly: Bool {
        return publishedStatus == .sampledataonly
    }
}

extension Source: Equatable {
    public static func == (lhs: Source, rhs: Source) -> Bool {
        return lhs.id == rhs.id
    }
}
