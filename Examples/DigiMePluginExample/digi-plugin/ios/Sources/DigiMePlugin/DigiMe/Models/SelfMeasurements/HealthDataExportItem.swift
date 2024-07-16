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
    var id: UUID
    var typeIdentifier: String
    var createdDate: Date
    var stringValue: String
    var parentId: String?
    @Attribute(.externalStorage) var jsonData: Data?
//    var jsonString: String?
    var isSelected = true
//    var isPushed = false

    init(typeIdentifier: String, createdDate: Date, stringValue: String, parentId: String? = nil, jsonData: Data? = nil/*, jsonString: String? = nil*/, isSelected: Bool = true/*, isPushed: Bool = false*/) {
        self.id = UUID()
        self.typeIdentifier = typeIdentifier
        self.createdDate = createdDate
        self.stringValue = stringValue
        self.parentId = parentId
        self.jsonData = jsonData
//        self.jsonString = jsonString
        self.isSelected = isSelected
//        self.isPushed = isPushed
    }

    enum CodingKeys: String, CodingKey {
        case id, typeIdentifier, createdDate, stringValue, parentId, jsonData, /*jsonString,*/ isSelected//, isPushed
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        typeIdentifier = try container.decode(String.self, forKey: .typeIdentifier)
        stringValue = try container.decode(String.self, forKey: .stringValue)
        parentId = try container.decode(String.self, forKey: .parentId)
        jsonData = try container.decodeIfPresent(Data.self, forKey: .jsonData)
//        jsonString = try container.decodeIfPresent(String.self, forKey: .jsonString)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
//        isPushed = try container.decode(Bool.self, forKey: .isPushed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(typeIdentifier, forKey: .typeIdentifier)
        try container.encode(stringValue, forKey: .stringValue)
        try container.encode(parentId, forKey: .parentId)
        try container.encodeIfPresent(jsonData, forKey: .jsonData)
//        try container.encodeIfPresent(jsonString, forKey: .jsonString)
        try container.encode(isSelected, forKey: .isSelected)
//        try container.encode(isPushed, forKey: .isPushed)
    }
}

extension HealthDataExportItem: Identifiable {
    static func == (lhs: HealthDataExportItem, rhs: HealthDataExportItem) -> Bool {
        return lhs.typeIdentifier == rhs.typeIdentifier
    }
}

extension HealthDataExportItem: Comparable {
    static func < (lhs: HealthDataExportItem, rhs: HealthDataExportItem) -> Bool {
        return lhs == rhs
    }
}
