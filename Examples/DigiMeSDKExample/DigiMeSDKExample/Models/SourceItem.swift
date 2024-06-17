//
//  SourceItem.swift
//  DigiMeSDKExample
//
//  Created on 05/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation
import SwiftData
import SwiftUI

@Model
class SourceItem: Codable, Identifiable {
    @Attribute(.unique) let id: Int
    let serviceGroupId: Int
    let contractId: String
    let sampleData: Bool
    let searchable: String
    let items: [DigiMeCore.Source]
    var readOptions: ReadOptions?

    init(id: Int, serviceGroupId: Int, contractId: String, sampleData: Bool, searchable: String, item: Source, readOptions: ReadOptions? = nil) {
        self.id = id
        self.serviceGroupId = serviceGroupId
        self.contractId = contractId
        self.sampleData = sampleData
        self.searchable = searchable
        self.items = [item]
        self.readOptions = readOptions
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.serviceGroupId = try container.decode(Int.self, forKey: .serviceGroupId)
        self.contractId = try container.decode(String.self, forKey: .contractId)
        self.sampleData = try container.decode(Bool.self, forKey: .sampleData)
        self.searchable = try container.decode(String.self, forKey: .searchable)
        self.items = try container.decode([Source].self, forKey: .items)
        self.readOptions = try container.decodeIfPresent(ReadOptions.self, forKey: .readOptions)
    }

    enum CodingKeys: CodingKey {
        case id
        case serviceGroupId
        case contractId
        case sampleData
        case searchable
        case items
        case readOptions
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.serviceGroupId, forKey: .serviceGroupId)
        try container.encode(self.contractId, forKey: .contractId)
        try container.encode(self.sampleData, forKey: .sampleData)
        try container.encode(self.searchable, forKey: .searchable)
        try container.encode(self.items, forKey: .items)
        try container.encodeIfPresent(self.readOptions, forKey: .readOptions)
    }
}
