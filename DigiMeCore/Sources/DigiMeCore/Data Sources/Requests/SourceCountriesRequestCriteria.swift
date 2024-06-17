//
//  SourceCountriesRequestCriteria.swift
//  DigiMeCore
//
//  Created on 08/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct SourceCountriesRequestCriteria: Codable {
    public var query: Query?

    public init(query: Query? = nil) {
        self.query = query
    }

    public enum FieldList: String, Codable {
        case id, name, code, json
        case resourceUrl = "resource.url"
        case resourceMimetype = "resource.mimetype"
        //case resourceResize = "resource.resize"
        //case resourceType = "resource.type"
    }

    public struct Query: Codable {
        public var include: [FieldList]?
        public var filter: SourceRequestFilter?

        public init(include: [FieldList]? = nil, filter: SourceRequestFilter? = nil) {
            self.include = include
            self.filter = filter
        }
    }
}
