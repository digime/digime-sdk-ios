//
//  HealthDataExportItem.swift
//  DigiMeSDKExample
//
//  Created on 13/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

@Model
class HealthDataExportItem {
    @Attribute(.unique) var id: String
    var typeIdentifier: String
    var createdDate: Date
    var stringValue: String
    var parentId: String?
    @Attribute(.externalStorage) var jsonData: Data?
    var isSelected = true

    init(id: String, typeIdentifier: String, createdDate: Date, stringValue: String, parentId: String? = nil, jsonData: Data? = nil, isSelected: Bool = true) {
        self.id = id
        self.typeIdentifier = typeIdentifier
        self.createdDate = createdDate
        self.stringValue = stringValue
        self.parentId = parentId
        self.jsonData = jsonData
        self.isSelected = isSelected
    }

    enum CodingKeys: String, CodingKey {
        case id, typeIdentifier, createdDate, stringValue, parentId, jsonData, isSelected
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        typeIdentifier = try container.decode(String.self, forKey: .typeIdentifier)
        stringValue = try container.decode(String.self, forKey: .stringValue)
        parentId = try container.decode(String.self, forKey: .parentId)
        jsonData = try container.decodeIfPresent(Data.self, forKey: .jsonData)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(typeIdentifier, forKey: .typeIdentifier)
        try container.encode(stringValue, forKey: .stringValue)
        try container.encode(parentId, forKey: .parentId)
        try container.encodeIfPresent(jsonData, forKey: .jsonData)
        try container.encode(isSelected, forKey: .isSelected)
    }
}

extension HealthDataExportItem: Identifiable {
    static func == (lhs: HealthDataExportItem, rhs: HealthDataExportItem) -> Bool {
        return lhs.id == rhs.id
    }
}

extension HealthDataExportItem: Comparable {
    static func < (lhs: HealthDataExportItem, rhs: HealthDataExportItem) -> Bool {
        return lhs == rhs
    }
}
