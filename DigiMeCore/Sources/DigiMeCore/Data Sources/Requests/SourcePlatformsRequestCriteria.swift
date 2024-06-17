//
//  SourcePlatformsRequestCriteria.swift
//  DigiMeCore
//
//  Created on 08/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct SourcePlatformsRequestCriteria: Codable {
    public var query: Query?

    public init(query: Query? = nil) {
        self.query = query
    }

    public enum FieldList: String, Codable {
        case id, json, name, reference
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
