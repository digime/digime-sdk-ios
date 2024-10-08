//
//  Previewer.swift
//  DigiMeSDKExample
//
//  Created on 11/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import DigiMeHealthKit
import Foundation
import SwiftData

@available(iOS 17.0, *)
@MainActor
struct Previewer {
    let container: ModelContainer
    let section1: HealthDataExportSection
    let section2: HealthDataExportSection
    let section3: HealthDataExportSection

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: HealthDataExportItem.self, HealthDataExportFile.self, HealthDataExportSection.self, configurations: config)

        let date1 = Date.date(year: 2012, month: 2, day: 4)
        let date2 = Date.date(year: 2015, month: 6, day: 8)
        let typeIdentifier1 = QuantityType.bodyMass.identifier!
        let item1 = HealthDataExportItem(id: UUID().uuidString, typeIdentifier: typeIdentifier1, createdDate: date1, stringValue: "82 kg")
        let item2 = HealthDataExportItem(id: UUID().uuidString, typeIdentifier: typeIdentifier1, createdDate: date2, stringValue: "90 kg")
        section1 = HealthDataExportSection(typeIdentifier: typeIdentifier1, itemsCount: 2, minDate: date1, maxDate: date2)
        container.mainContext.insert(section1)
        container.mainContext.insert(item1)
        container.mainContext.insert(item2)

        let typeIdentifier2 = QuantityType.height.identifier!
        let item3 = HealthDataExportItem(id: UUID().uuidString, typeIdentifier: typeIdentifier1, createdDate: date1, stringValue: "180 cm")
        let item4 = HealthDataExportItem(id: UUID().uuidString, typeIdentifier: typeIdentifier1, createdDate: date2, stringValue: "200 cm")
        section2 = HealthDataExportSection(typeIdentifier: typeIdentifier2, itemsCount: 2, minDate: date1, maxDate: date2)
        container.mainContext.insert(section2)
        container.mainContext.insert(item3)
        container.mainContext.insert(item4)

        let typeIdentifier3 = CorrelationType.bloodPressure.identifier!
        let item5 = HealthDataExportItem(id: UUID().uuidString, typeIdentifier: typeIdentifier1, createdDate: date1, stringValue: "200 mm/Hg, 30 mm/Hg")
        let item6 = HealthDataExportItem(id: UUID().uuidString, typeIdentifier: typeIdentifier1, createdDate: date2, stringValue: "170 mm/Hg, 60 mm/Hg")
        section3 = HealthDataExportSection(typeIdentifier: typeIdentifier3, itemsCount: 2, minDate: date1, maxDate: date2)
        container.mainContext.insert(section3)
        container.mainContext.insert(item5)
        container.mainContext.insert(item6)

        let file1 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierBodyMass", fileName: "file name 1", createdDate: Date(), dataStartDate: Date.date(year: 2020, month: 4, day: 22), dataEndDate: Date.date(year: 2023, month: 7, day: 30), fileURL: URL(fileURLWithPath: ""), itemCount: 20, state: .idle)
        container.mainContext.insert(file1)
        let file2 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierBodyTemperature", fileName: "file name 2", createdDate: Date(), dataStartDate: Date.date(year: 2018, month: 4, day: 22), dataEndDate: Date.date(year: 2020, month: 3, day: 5), fileURL: URL(fileURLWithPath: ""), itemCount: 200, state: .uploading)
        container.mainContext.insert(file2)
        let file3 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierOxygenSaturation", fileName: "file name 3", createdDate: Date(), dataStartDate: Date.date(year: 2008, month: 1, day: 1), dataEndDate: Date.date(year: 2009, month: 9, day: 6), fileURL: URL(fileURLWithPath: ""), itemCount: 3, state: .uploaded)
        container.mainContext.insert(file3)
        let file4 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierOxygenSaturation", fileName: "file name 4", createdDate: Date(), dataStartDate: Date.date(year: 2000, month: 3, day: 5), dataEndDate: Date.date(year: 2001, month: 10, day: 5), fileURL: URL(fileURLWithPath: ""), itemCount: 10, state: .error)
        container.mainContext.insert(file4)
    }
}
#endif
