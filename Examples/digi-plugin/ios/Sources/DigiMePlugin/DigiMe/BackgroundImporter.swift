//
//  BackgroundImporter.swift
//  DigiMeSDKExample
//
//  Created on 16/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import DigiMeCore
import DigiMeHealthKit
import Foundation
import SwiftData

/// Import Apple Health data into local database
@available(iOS 17.0, *)
class BackgroundImporter {
    private let persistenceActor: BackgroundSerialPersistenceActor

    init(modelContainer: ModelContainer) {
        self.persistenceActor = BackgroundSerialPersistenceActor(container: modelContainer)
    }

    func convertObjects(_ data: [PayloadIdentifiable], converter: FHIRObservationConverter, aggregationType: AggregationType, completion: @escaping ((Error?) -> Void)) {
        Task {
            do {
                let type = converter.dataConverterType()
                guard let typeIdentifier = type.identifier else {
                    completion(SDKError.healthDataError(message: "Error. Object converter failed for a type - \(type). Expected data converter type identifier."))
                    return
                }

                let sectionFetchDescriptor = FetchDescriptor<HealthDataExportSection>(predicate: #Predicate { $0.typeIdentifier == typeIdentifier })
                let sections = try await persistenceActor.fetchData(predicate: sectionFetchDescriptor.predicate)
                let section = sections.first ?? HealthDataExportSection(typeIdentifier: type.identifier!)

                if sections.isEmpty {
                    try await persistenceActor.insert(data: section)
                    try await persistenceActor.save()
                }

                let batchSize = calculateDynamicBatchSize(for: data.count)
                var items: [HealthDataExportItem] = []

                for (index, element) in data.enumerated() {
                    if let observation = converter.convertToObservation(data: element, aggregationType: aggregationType),
                       let jsonData = try? observation.encoded(outputFormatting: [.withoutEscapingSlashes]) {

                        let itemCreatedDate = converter.getCreatedDate(data: element)
                        let item = HealthDataExportItem(id: element.id, typeIdentifier: typeIdentifier, createdDate: itemCreatedDate, stringValue: converter.getFormattedValueString(data: element), parentId: section.id.uuidString, jsonData: jsonData)
                        items.append(item)
                        section.update(item.createdDate)

                        if items.count == batchSize || index == data.count - 1 {
                            for item in items {
                                try await persistenceActor.insert(data: item)
                            }
                            try await persistenceActor.save()
                            items.removeAll()
                        }
                    } else {
                        print("Error. Observation ignored. FHIR data export failed for data type: \(type), \(dump(element))")
                    }
                }

                try await persistenceActor.insert(data: section)
                try await persistenceActor.save()

                completion(nil)
            } 
            catch {
                completion(error)
            }
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
#endif
