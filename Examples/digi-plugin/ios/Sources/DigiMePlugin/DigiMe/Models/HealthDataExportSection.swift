//
//  HealthDataExportSection.swift
//  DigiMeSDKExample
//
//  Created on 03/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import Combine
import Foundation
import SwiftData
import SwiftUI

@available(iOS 17.0, *)
@Model
class HealthDataExportSection: Identifiable {
    var id: UUID
    var typeIdentifier: String
    var itemsCount: Int
    var minDate: Date?
    var maxDate: Date?
    var exportSelected = true

    init(typeIdentifier: String, itemsCount: Int = 0, minDate: Date? = nil, maxDate: Date? = nil, exportSelected: Bool = true) {
        self.id = UUID()
        self.typeIdentifier = typeIdentifier
        self.itemsCount = itemsCount
        self.minDate = minDate
        self.maxDate = maxDate
        self.exportSelected = exportSelected
    }

    func update(_ itemCreatedDate: Date) {
        // Check if minDate and maxDate should be extended to include the new created date of the new iported item
        minDate = min(minDate ?? itemCreatedDate, itemCreatedDate)
        maxDate = max(maxDate ?? itemCreatedDate, itemCreatedDate)

        itemsCount += 1
    }
}

@available(iOS 17.0, *)
extension HealthDataExportSection: Comparable {
    static func < (lhs: HealthDataExportSection, rhs: HealthDataExportSection) -> Bool {
        return lhs.typeIdentifier < rhs.typeIdentifier
    }
}

@available(iOS 17.0, *)
extension HealthDataExportSection: Equatable {
    static func == (lhs: HealthDataExportSection, rhs: HealthDataExportSection) -> Bool {
        return lhs.typeIdentifier == rhs.typeIdentifier
    }
}
#endif
