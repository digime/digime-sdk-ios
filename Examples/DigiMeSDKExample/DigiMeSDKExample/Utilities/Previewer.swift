//
//  Previewer.swift
//  DigiMeSDKExample
//
//  Created on 11/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeHealthKit
import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let logEntry1: LogEntry
    let logEntry2: LogEntry
    let logEntry3: LogEntry
    let logEntry4: LogEntry
    let measurement: SelfMeasurement
    let section1: HealthDataExportSection
    let section2: HealthDataExportSection
    let section3: HealthDataExportSection

    let sourceItem1: SourceItem

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: LogEntry.self, SelfMeasurement.self, SelfMeasurementComponent.self, SelfMeasurementReceipt.self, HealthDataExportItem.self, HealthDataExportFile.self, HealthDataExportSection.self, SourceItem.self, configurations: config)

        // Logs

        logEntry1 = LogEntry(message: "an error occured", state: .error)
        logEntry2 = LogEntry(message: "warning message", state: .warning)
        logEntry3 = LogEntry(message: "normal activity registered")
        logEntry4 = LogEntry(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")

        container.mainContext.insert(logEntry1)
        container.mainContext.insert(logEntry2)
        container.mainContext.insert(logEntry3)
        container.mainContext.insert(logEntry4)

        // Discovery objects

        let sources = TestDiscoveryObjects.sources
        sourceItem1 = SourceItem(id: 1, serviceGroupId: 1, contractId: "testContractId", sampleData: false, searchable: sources.first?.name ?? "n/a", item: sources.first!)
        container.mainContext.insert(sourceItem1)

        for source in sources {
            let item = SourceItem(id: source.id, serviceGroupId: source.category.first!.id, contractId: "testContractId", sampleData: source.publishedStatus == .sampledataonly, searchable: source.name, item: source)
            container.mainContext.insert(item)
        }

        // Self measurements

        measurement = SelfMeasurement(name: "Height",
                                      type: SelfMeasurementType.height,
                                      createdDate: Date(),
                                      components: [SelfMeasurementComponent(measurementValue: 80, unit: "cm", unitCode: "cm", display: "cm")],
                                      receipts: [SelfMeasurementReceipt(providerName: "NL - Zorgaanbieder1 (Meetwaardenvitale functies)", shareDate: Date())])
        container.mainContext.insert(measurement)

        // Apple Health import

        let date1 = Date.randomDateRange()
        let typeIdentifier1 = QuantityType.bodyMass.identifier!
        let item1 = HealthDataExportItem(typeIdentifier: typeIdentifier1, createdDate: date1.start, stringValue: "82 kg")
        section1 = HealthDataExportSection(typeIdentifier: typeIdentifier1, itemsCount: 1, minDate: date1.start, maxDate: date1.end)
        container.mainContext.insert(section1)
        container.mainContext.insert(item1)

        let date2 = Date.randomDateRange()
        let typeIdentifier2 = QuantityType.height.identifier!
        let item3 = HealthDataExportItem(typeIdentifier: typeIdentifier2, createdDate: date2.start, stringValue: "180 cm")
        section2 = HealthDataExportSection(typeIdentifier: typeIdentifier2, itemsCount: 1, minDate: date2.start, maxDate: date2.end)
        container.mainContext.insert(section2)
        container.mainContext.insert(item3)

        let date3 = Date.randomDateRange()
        let item5 = HealthDataExportItem(typeIdentifier: CorrelationType.bloodPressure.identifier!, createdDate: date3.start, stringValue: "200 mm/Hg, 30 mm/Hg")
        section3 = HealthDataExportSection(typeIdentifier: CorrelationType.bloodPressure.identifier!, itemsCount: 1, minDate: date3.start, maxDate: date3.end)
        container.mainContext.insert(section3)
        container.mainContext.insert(item5)

        // Apple Health export

        let file1 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierBodyMass", fileName: "file name 1", createdDate: date1.start, dataStartDate: date1.start, dataEndDate: date1.end, fileURL: URL(fileURLWithPath: ""), itemCount: 20, state: .idle)
        container.mainContext.insert(file1)
        let file2 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierBodyTemperature", fileName: "file name 2", createdDate: date2.start, dataStartDate: date2.start, dataEndDate: date2.end, fileURL: URL(fileURLWithPath: ""), itemCount: 200, state: .uploading)
        container.mainContext.insert(file2)
        let file3 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierOxygenSaturation", fileName: "file name 3", createdDate: date3.start, dataStartDate: date3.start, dataEndDate: date3.end, fileURL: URL(fileURLWithPath: ""), itemCount: 3, state: .uploaded)
        container.mainContext.insert(file3)
        let file4 = HealthDataExportFile(typeIdentifier: "HKQuantityTypeIdentifierOxygenSaturation", fileName: "file name 4", createdDate: date1.start, dataStartDate: date1.start, dataEndDate: date1.end, fileURL: URL(fileURLWithPath: ""), itemCount: 10, state: .error)
        container.mainContext.insert(file4)
    }
}
