//
//  ServiceGroupType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents a service group scope with which data requests can be limited to
public struct ServiceGroupType: Codable, Identifiable {
    public var id: Int
    public var name: String?
    public var serviceTypes: [ServiceType]?
//    public let json: ServiceGroupMetadata?
//    public let categoryTypeId: Int?
//    public let reference: String?
//    public let resource: SourceResource?
//    public let subTitle: String?
//    public let title: String?
//    public let expandedTitle: String?
//    public let expandedSubTitle: String?
    
    /// Initializes a new instance of `ServiceGroupType`.
    ///
    /// A service group is a top-level category grouping similar services, such as Social, Fitness, etc.
    /// This initializer sets up a service group with specific characteristics and metadata that can be used
    /// to further define or restrict the service group's behavior in the application.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the service group. This is used to uniquely identify the group within the system.
    ///   - name: An optional name for the service group. This is a convenience property that can be used to display a human-readable name for the group.
    ///   - serviceTypes: An optional array of `ServiceType` objects associated with the service group. If an empty array is passed, or the parameter is nil, all services associated with the group will be included.
    ///   - json: An optional `ServiceGroupMetadata` object containing additional metadata or configuration in JSON format specific to this service group.
    ///   - categoryTypeId: An optional identifier categorizing the type of the service group. This can be used to classify service groups into different types or categories.
    ///   - reference: An optional string that can be used to store a reference identifier or a note related to the service group.
    ///   - resource: An optional `SourceResource` object representing additional resources or information related to the service group.
    ///   - subTitle: An optional subtitle for the service group. This can provide additional context or description in a UI, complementing the main title.
    ///   - title: An optional title for the service group. This can be used in user interfaces where the name of the service group is displayed.
    ///   - expandedTitle: An optional expanded version of the title. This can be used in contexts where a more detailed or descriptive title is needed.
    ///   - expandedSubTitle: An optional expanded version of the subtitle. This provides an opportunity to include additional descriptive text or details about the service group.
    ///
    /// See https://developers.digi.me/reference-objects#service-group for a list of service group identifiers.
//    public init(identifier: Int, name: String? = nil, serviceTypes: [ServiceType]? = nil, json: ServiceGroupMetadata? = nil, categoryTypeId: Int? = nil, reference: String? = nil, resource: SourceResource? = nil, subTitle: String? = nil, title: String? = nil, expandedTitle: String? = nil, expandedSubTitle: String? = nil) {
//        self.id = identifier
//        self.name = name
//        self.serviceTypes = serviceTypes
//        self.json = json
//        self.categoryTypeId = categoryTypeId
//        self.reference = reference
//        self.resource = resource
//        self.subTitle = subTitle
//        self.title = title
//        self.expandedTitle = expandedTitle
//        self.expandedSubTitle = expandedSubTitle
//    }

    public init(id: Int, name: String? = nil, serviceTypes: [ServiceType]? = nil) {
        self.id = id
        self.name = name
        self.serviceTypes = serviceTypes
    }
}

public struct ServiceGroupMetadata: Codable {
    public var expandedSubTitle: String
    public var expandedTitle: String
    public var subTitle: String
    public var title: String
}
