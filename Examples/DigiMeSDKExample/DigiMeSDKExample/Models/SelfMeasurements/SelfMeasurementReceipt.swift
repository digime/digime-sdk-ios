//
//  SelfMeasurementReceipt.swift
//  DigiMeSDKExample
//
//  Created on 07/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

@Model
class SelfMeasurementReceipt: Codable, Hashable {
    var id: UUID
    var providerName: String
    var shareDate: Date

    init(providerName: String, shareDate: Date) {
        self.id = UUID()
        self.providerName = providerName
        self.shareDate = shareDate
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        providerName = try container.decode(String.self, forKey: .providerName)
        shareDate = try container.decode(Date.self, forKey: .shareDate)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(providerName, forKey: .providerName)
        try container.encode(id, forKey: .shareDate)
    }

    enum CodingKeys: String, CodingKey {
        case id, providerName, shareDate
    }
}

extension SelfMeasurementReceipt: Identifiable {
    static func == (lhs: SelfMeasurementReceipt, rhs: SelfMeasurementReceipt) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SelfMeasurementReceipt: Comparable {
    static func < (lhs: SelfMeasurementReceipt, rhs: SelfMeasurementReceipt) -> Bool {
        return lhs == rhs
    }
}
