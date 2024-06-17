//
//  BackgroundImporter.swift
//  DigiMeSDKExample
//
//  Created on 16/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import Foundation
import SwiftData

/// Import Apple Health data into local database
class BackgroundImporter {
    private var modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func convertObjects(_ data: [PayloadIdentifiable], converter: FHIRObservationConverter, completion: @escaping ((Error?) -> Void)) {
        autoreleasepool {
            let type = converter.dataConverterType()
            guard let typeIdentifier = type.identifier else {
                completion(SDKError.healthDataError(message: "Error. Object converter failed for a type - \(type). Expected data converter type identifier."))
                return
            }

            let modelContext = ModelContext(modelContainer)
            modelContext.autosaveEnabled = false
            let batchSize = calculateDynamicBatchSize(for: data.count)
            let sectionFetchDescriptor = FetchDescriptor<HealthDataExportSection>(predicate: #Predicate { $0.typeIdentifier == typeIdentifier })
            let section = (try? modelContext.fetch(sectionFetchDescriptor).first) ?? HealthDataExportSection(typeIdentifier: type.identifier!)
            var items: [HealthDataExportItem] = []
            modelContext.insert(section)
            try? modelContext.save()

            for (index, element) in data.enumerated() {
                if
                    let observation = converter.convertToObservation(data: element),
                    let jsonData = try? observation.encoded(outputFormatting: [.withoutEscapingSlashes]) {
                    // let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as? JSON {

                    let itemCreatedDate = converter.getCreatedDate(data: element)

                    // let encoder = JSONEncoder()
                    // encoder.outputFormatting = .withoutEscapingSlashes
                    // if let data2 = try? encoder.encode(observation) {
                    //  print("data2: \(try? data2.encodedToString())")
                    // }
                    //
                    // print("data1: \(String(data: jsonData, encoding: .utf8))")
                    // print("obj: \(try? observation.encodedToString())")
                    let item = HealthDataExportItem(typeIdentifier: typeIdentifier, createdDate: itemCreatedDate, stringValue: converter.getFormattedValueString(data: element), parentId: section.id.uuidString, jsonData: jsonData)
                    items.append(item)
                    section.update(item.createdDate)

                    if items.count == 1 {
                        // show some progress in the UI before the end of the batch size
                        try? modelContext.save()
                    }

                    if items.count == batchSize || index == data.count - 1 {
                        let itemsToSave = items
                        for item in itemsToSave {
                            modelContext.insert(item)
                        }
                        try? modelContext.save()
                        items.removeAll()
                    }
                }
                else {
                    completion(SDKError.healthDataError(message: "Error. Observation ignored. FHIR data export failed for data type: \(type)"))
                }
            }

            completion(nil)
        }
    }

    private func calculateDynamicBatchSize(for totalItems: Int) -> Int {
        let basePercentage = 0.01
        let minimumBatchSize = 100
        let maximumBatchSize = 10_000

        let dynamicSize = Int(Double(totalItems) * basePercentage)
        return max(minimumBatchSize, min(maximumBatchSize, dynamicSize))
    }
}
