//
//  BackgroundExporter.swift
//  DigiMeSDKExample
//
//  Created on 18/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import DigiMeCore
import DigiMeHealthKit
import Foundation
import SwiftData

/// Export Apple Health data from local database and save it to the app' documents folder
@available(iOS 17.0, *)
class BackgroundExporter: ObservableObject {
    private let persistenceActor: BackgroundSerialPersistenceActor
    private var urlsToExport = [URL]()
    private let urlsQueue = DispatchQueue(label: "com.backgroundexporter.urlsQueue")
    private var processedParentIds = Set<String>()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMMM"
        return formatter
    }()

    private static let exportTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()

    init(modelContainer: ModelContainer) {
        self.persistenceActor = BackgroundSerialPersistenceActor(container: modelContainer)
    }

    func loadSectionIds(completion: @escaping (Result<[String], Error>) -> Void) {
        Task {
            do {
                let sections = try await persistenceActor.fetchData(
                    predicate: #Predicate<HealthDataExportSection> { $0.exportSelected && $0.itemsCount > 0 }
                )
                let sectionIds = sections.map { $0.id.uuidString }
                await MainActor.run {
                    completion(.success(sectionIds))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    func shareAllData(for parentIds: [String], locally: Bool, downloadHandler: ((Result<HealthDataExportFileHandler, SDKError>) -> Void)? = nil, completion: @escaping (([URL]?, Error?) -> Void)) {
        guard !parentIds.isEmpty else {
            completion([], nil)
            return
        }

        urlsToExport = []
        processedParentIds.removeAll()

        Task(priority: .background) {
            do {
                for parentId in parentIds {
                    try await self.processParentId(parentId, locally: locally, downloadHandler: downloadHandler)
                }
                await MainActor.run {
                    completion(self.urlsToExport, nil)
                }
            } catch {
                await MainActor.run {
                    completion(nil, error)
                }
            }
        }
    }

    private func processParentId(_ parentId: String, locally: Bool, downloadHandler: ((Result<HealthDataExportFileHandler, SDKError>) -> Void)? = nil) async throws {
        guard !processedParentIds.contains(parentId) else {
            return // Skip if already processed
        }
        processedParentIds.insert(parentId)

        let totalItems = try await persistenceActor.fetchCount(
            predicate: #Predicate<HealthDataExportItem> { $0.parentId == parentId }
        )
        let batchSize = self.calculateDynamicBatchSize(for: totalItems)

        for batchStart in stride(from: 0, to: totalItems, by: batchSize) {
            let batchItems = try await fetchBatchItems(for: parentId, batchStart: batchStart, batchSize: batchSize)
            try await processBatch(items: batchItems, locally: locally, downloadHandler: downloadHandler)
        }
    }

    private func processBatch(items: [HealthDataExportItem], locally: Bool, downloadHandler: ((Result<HealthDataExportFileHandler, SDKError>) -> Void)? = nil) async throws {
        guard let typeIdentifier = items.first?.typeIdentifier else {
            throw SDKError.unknown(message: "No type identifier found")
        }

        let processedData: ([JSON], Date, Date) = try await Task(priority: .background) {
            autoreleasepool {
                let dataToExport = items.compactMap { item -> JSON? in
                    guard let jsonData = item.jsonData,
                          let jsonObject = self.processJSONData(jsonData) else { return nil }
                    return jsonObject
                }

                let fromDate = items.min { $0.createdDate < $1.createdDate }?.createdDate ?? Date(timeIntervalSince1970: 0)
                let toDate = items.max { $0.createdDate < $1.createdDate }?.createdDate ?? Date()

                return (dataToExport, fromDate, toDate)
            }
        }.value

        // Generate fileName as before...

        let (dataToExport, fromDate, toDate) = processedData

        let typeName = HealthDataType(typeIdentifier: typeIdentifier)?.name.replacingOccurrences(of: " ", with: "_") ?? "unknown"
        let fromString = Self.dateFormatter.string(from: fromDate)
        let toString = Self.dateFormatter.string(from: toDate)
        let exportTime = Self.exportTimeFormatter.string(from: Date())
        let fileName = "AH_\(typeName)_\(fromString)-\(toString)_items_\(items.count)_export_\(exportTime).json"

        // Serialize data and write to disk
        let fileResult = try await Task(priority: .background) {
            let jsonData = try JSONSerialization.data(withJSONObject: dataToExport, options: [.withoutEscapingSlashes])
            let filePersistentStorage = FilePersistentStorage(with: .documentDirectory)
            guard let shareUrl = filePersistentStorage.store(data: jsonData, fileName: fileName) else {
                throw SDKError.unknown(message: "Failed to save HealthDataExportFile to disk")
            }
            return (jsonData, shareUrl)
        }.value

        let (jsonData, shareUrl) = fileResult

        // Update urlsToExport safely
        self.urlsQueue.sync {
            self.urlsToExport.append(shareUrl)
        }

        // Perform database operations
        if !locally {
            try await persistenceActor.insert(data: HealthDataExportFile(
                typeIdentifier: typeIdentifier,
                fileName: fileName,
                createdDate: Date(),
                dataStartDate: fromDate,
                dataEndDate: toDate,
                fileURL: shareUrl,
                itemCount: items.count
            ))
            try await persistenceActor.save()

            await MainActor.run {
                downloadHandler?(.success(HealthDataExportFileHandler(
                    id: UUID(),
                    typeIdentifier: typeIdentifier,
                    fileName: fileName,
                    data: jsonData,
                    uploadState: .idle
                )))
            }
        }
    }

    private func processJSONData(_ data: Data) -> JSON? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? JSON
        } catch {
            print("Failed to convert to JSON: \(error)")
            return nil
        }
    }

    private func fetchBatchItems(for parentId: String, batchStart: Int, batchSize: Int) async throws -> [HealthDataExportItem] {
        return try await persistenceActor.fetchData(
            predicate: #Predicate<HealthDataExportItem> { $0.parentId == parentId },
            sortBy: [SortDescriptor(\HealthDataExportItem.createdDate)],
            fetchLimit: batchSize,
            fetchOffset: batchStart
        )
    }

    private func calculateDynamicBatchSize(for totalItems: Int) -> Int {
        let basePercentage = 0.1
        let minimumBatchSize = 100
        let maximumBatchSize = 50_000

        let dynamicSize = Int(Double(totalItems) * basePercentage)
        return max(minimumBatchSize, min(maximumBatchSize, dynamicSize))
    }
}
#endif
