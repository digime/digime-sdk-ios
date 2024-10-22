//
//  SourceRequestFilter.swift
//  DigiMeCore
//
//  Created on 08/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public struct SourceRequestFilter: Codable {
    public var id: [Int]?

    public init(id: [Int]? = nil) {
        self.id = id
    }
}
