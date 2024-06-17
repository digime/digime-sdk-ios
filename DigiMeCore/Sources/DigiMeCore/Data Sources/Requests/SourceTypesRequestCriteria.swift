//
//  SourceTypesRequestCriteria.swift
//  DigiMeCore
//
//  Created on 08/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct SourceTypesRequestCriteria: Codable {
    public var query: Query?

    public init(query: Query? = nil) {
        self.query = query
    }

    public enum SelectableField: String, Codable {
        case id, name, reference
    }

    public struct Query: Codable {
        public var include: [SelectableField]?
        public var filter: SourceRequestFilter?

        public init(include: [SelectableField]? = nil, filter: SourceRequestFilter? = nil) {
            self.include = include
            self.filter = filter
        }
    }
}
