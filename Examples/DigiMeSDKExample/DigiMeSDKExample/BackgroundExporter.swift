//
//  BackgroundExporter.swift
//  DigiMeSDKExample
//
//  Created on 18/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import Foundation
import SwiftData

protocol ExporterDelegate: AnyObject {
    func exporterDidUpdateProgress(_ progress: Int)
}

/// Export Apple Health data from local database and save it to the app' documents folder
class BackgroundExporter: ObservableObject {
    private var modelContainer: ModelContainer
    private weak var delegate: ExporterDelegate?

    private var progressCount: Int = 0
    private var urlsToExport = [URL]()
    private let urlsQueue = DispatchQueue(label: "com.backgroundexporter.urlsQueue") // Serial queue for thread-safe access to urlsToExport

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMMM"
        return formatter
    }()

    @Published private(set) var progress: Int = 0 {
        didSet {
            Task { @MainActor in
                self.delegate?.exporterDidUpdateProgress(self.progress)
            }
        }
    }

    init(modelContainer: ModelContainer, delegate: ExporterDelegate? = nil) {
        self.modelContainer = modelContainer
        self.delegate = delegate
    }

    /// Main function to share all data for the provided parent IDs.
    /// This function is asynchronous and performs its work on a background thread.
    func shareAllData(for parentIds: [String], locally: Bool, downloadHandler: ((Result<HealthDataExportFileHandler, SDKError>) -> Void)? = nil, completion: @escaping (([URL]?, Error?) -> Void)) {
        guard !parentIds.isEmpty else {
            return
        }

        progress = 0
        progressCount = 0
        urlsToExport = []

        // Detach the task to run concurrently
        Task.detached {
            // Using a throwing task group to handle multiple parent IDs concurrently
            await withThrowingTaskGroup(of: Void.self) { group in
                for parentId in parentIds {
                    group.addTask {
                        try await self.processParentId(parentId, locally: locally, downloadHandler: downloadHandler)
                    }
                }

                do {
                    // Wait for all tasks in the group to complete
                    try await group.waitForAll()
                } 
                catch {
                    // Handle any errors that occurred during the processing
                    Task { @MainActor in
                        completion(nil, error)
                    }
                    return
                }
            }

            // Completion callback with the URLs of the exported files
            Task { @MainActor in
                completion(self.urlsToExport, nil)
            }
        }
    }

    /// Process a single parent ID. Fetches data in batches and handles each batch separately.
    private func processParentId(_ parentId: String, locally: Bool, downloadHandler: ((Result<HealthDataExportFileHandler, SDKError>) -> Void)? = nil) async throws {
        let fetchDescriptor = FetchDescriptor<HealthDataExportItem>(predicate: #Predicate { $0.parentId == parentId })
        let context = ModelContext(self.modelContainer)
        let totalItems = try context.fetchCount(fetchDescriptor) // Fetch the total count of items
        let batchSize = self.calculateDynamicBatchSize(for: totalItems) // Calculate the batch size dynamically

        for batchStart in stride(from: 0, to: totalItems, by: batchSize) {
            try await self.processBatch(parentId: parentId, batchStart: batchStart, batchSize: batchSize, locally: locally, downloadHandler: downloadHandler)
        }
    }

    /// Process a single batch of data. Converts items to JSON and saves them to disk.
    private func processBatch(parentId: String, batchStart: Int, batchSize: Int, locally: Bool, downloadHandler: ((Result<HealthDataExportFileHandler, SDKError>) -> Void)? = nil) async throws {
        autoreleasepool {
            do {
                let batchItems = try self.fetchBatchItems(for: parentId, batchStart: batchStart, batchSize: batchSize)
                let data = batchItems.compactMap { $0.jsonData }
                var dataToExport: [JSON] = []

                data.forEach { jsonData in
                    self.progressCount += 1
                    
                    if self.progressCount.isMultiple(of: 100) {
                        Task { @MainActor in
                            self.progress = self.progressCount // Update progress on the main thread
                        }
                    }

                    if let jsonObject = self.processJSONData(jsonData) {
                        dataToExport.append(jsonObject)
                    } 
                    else {
                        print("failed to convert to json")
                    }
                }

                guard let typeIdentifier = batchItems.first?.typeIdentifier else {
                    Task { @MainActor in
                        downloadHandler?(.failure(SDKError.unknown(message: "No type identifier found")))
                    }
                    return
                }

                let typeName = HealthDataType(typeIdentifier: typeIdentifier)?.name.replacingOccurrences(of: " ", with: "_") ?? "unknown"
                let fromDate = batchItems.min { $0.createdDate < $1.createdDate }?.createdDate ?? Date(timeIntervalSince1970: 0)
                let toDate = batchItems.max { $0.createdDate < $1.createdDate }?.createdDate ?? Date(timeIntervalSinceNow: 0)
                let fromString = Self.dateFormatter.string(from: fromDate)
                let toString = Self.dateFormatter.string(from: toDate)
                let fileName = "AH_\(typeName)_\(fromString)-\(toString)_items_\(batchItems.count).json"

                if let jsonData = try? JSONSerialization.data(withJSONObject: dataToExport, options: [.withoutEscapingSlashes]),
                   let shareUrl = FileHelper.saveToDocumentDirectory(data: jsonData, fileName: fileName) {

                    // Safely append to urlsToExport
                    self.urlsQueue.sync {
                        self.urlsToExport.append(shareUrl)
                    }

                    if !locally {
                        let file = HealthDataExportFile(typeIdentifier: typeIdentifier, fileName: fileName, createdDate: Date(), dataStartDate: fromDate, dataEndDate: toDate, fileURL: shareUrl, itemCount: batchItems.count)
                        let handler = HealthDataExportFileHandler(id: file.id, typeIdentifier: typeIdentifier, fileName: fileName, data: jsonData, uploadState: .idle)
                        let modelContext = ModelContext(self.modelContainer)
                        modelContext.insert(file)
                        try? modelContext.save()

                        // Inform the delegate about the successful file creation
                        Task { @MainActor in
                            downloadHandler?(.success(handler))
                        }
                    }
                } 
                else {
                    Task { @MainActor in
                        downloadHandler?(.failure(SDKError.unknown(message: "Failed to save HealthDataExportFile to disk")))
                    }
                }
            } 
            catch {
                print("Error fetching batch: \(error)")
            }
        }
    }

    /// Process JSON data from a Data object and return a JSON object.
    private func processJSONData(_ data: Data) -> JSON? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? JSON
        } catch {
            print("Failed to convert to JSON: \(error)")
            return nil
        }
    }

    /// Fetch a batch of items for a given parent ID, starting at a specific offset.
    private func fetchBatchItems(for parentId: String, batchStart: Int, batchSize: Int) throws -> [HealthDataExportItem] {
        let modelContext = ModelContext(self.modelContainer)
        modelContext.autosaveEnabled = false
        var batchDescriptor = FetchDescriptor<HealthDataExportItem>(predicate: #Predicate { $0.parentId == parentId })
        batchDescriptor.fetchLimit = batchSize
        batchDescriptor.fetchOffset = batchStart

        return try modelContext.fetch(batchDescriptor)
    }

    /// Calculate a dynamic batch size based on the total number of items.
    private func calculateDynamicBatchSize(for totalItems: Int) -> Int {
        let basePercentage = 0.1
        let minimumBatchSize = 100
        let maximumBatchSize = 50_000

        let dynamicSize = Int(Double(totalItems) * basePercentage)
        return max(minimumBatchSize, min(maximumBatchSize, dynamicSize))
    }
}
