//
//  HealthDataViewModel.swift
//  DigiMeSDKExample
//
//  Created on 22/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeCore
import DigiMeHealthKit
import DigiMeSDK
import Foundation
import SwiftData
import SwiftUI

@MainActor
class HealthDataViewModel: ObservableObject {
    @Published var shareLocally = false
    @Published var isLoadingData = false
    @Published var showErrorBanner = false
    @Published var showSuccessBanner = false
    @Published var showFinishConfirmationDialog = false
    @Published var exportAutomatically = true
    @Published var allToggled = true
    @Published var importFinished = false
    @Published var exportFinished = false
    @Published var showDetailedView = false
    @Published var isExporting = false {
        didSet {
            print("isExporting changed to \(isExporting)")
        }
    }
    @Published var backgroundWorkStartTime: Date?
    @Published var importElapsedTime: TimeInterval = 0
    @Published var exportElapsedTime: TimeInterval = 0
    @Published var numberOfExportedFiles: Int = 0
    @Published var error: Error?
    @Published var successMessage: String?
    @Published var healthDataTypes: [HealthDataType] = []
    @Published var progressMessage = "importingData".localized()
    @Published var sections: [HealthDataExportSection] = []
    @Published var totalItemsCount: Int = 0
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var aggregationOption: AggregationType = .daily

    var shareUrls: [URL]?
    var modelContainer: ModelContainer

    private let persistenceActor: BackgroundSerialPersistenceActor

    private var healthDataService: HealthDataService
    private var backgroundExporter: BackgroundExporter
    private var cloudId: String
    private var onComplete: ((Result<[String], Error>) -> Void)?
    private var intervalFormatter: DateComponentsFormatter {
        let fm = DateComponentsFormatter()
        fm.allowedUnits = [.hour, .minute, .second]
        fm.unitsStyle = .abbreviated
        fm.zeroFormattingBehavior = .pad
        return fm
    }

    init(modelContainer: ModelContainer, cloudId: String, onComplete: ((Result<[String], Error>) -> Void)?) {
        self.modelContainer = modelContainer
        self.persistenceActor = BackgroundSerialPersistenceActor(container: modelContainer)
        self.cloudId = cloudId
        self.onComplete = onComplete
        self.healthDataService = HealthDataService(modelContainer: modelContainer)
        self.backgroundExporter = BackgroundExporter(modelContainer: modelContainer)

        initToggles()
        updateAllToggledState()
    }

    var canProceed: Bool {
        return !isLoadingData && healthDataTypes.contains { $0.isToggled }
    }

    var authorisationTypes: [QuantityType: AggregationType] {
        let selectedTypes = healthDataTypes.filter { $0.isToggled }.compactMap { $0.type as? QuantityType }
        return Dictionary(uniqueKeysWithValues: selectedTypes.map { ($0, aggregationOption) })
    }

    // MARK: - Control Handlers

    private var readyToExport: Bool {
        guard !sections.isEmpty else {
            return false
        }

        return sections.contains { section in
            section.itemsCount > 0 && section.exportSelected
        }
    }

    func resetAllData() async {
        isLoadingData = true

        do {
            // Clear all data in the database
            try await persistenceActor.remove(predicate: #Predicate<HealthDataExportSection> { _ in true })
            try await persistenceActor.remove(predicate: #Predicate<HealthDataExportFile> { _ in true })
            try await persistenceActor.remove(predicate: #Predicate<HealthDataExportItem> { _ in true })

            // Reset sections
            sections.removeAll()

            totalItemsCount = 0
            error = nil
            successMessage = nil
            importFinished = false
            exportFinished = false
            isExporting = false
            exportAutomatically = true
            backgroundWorkStartTime = nil
            importElapsedTime = 0
            exportElapsedTime = 0

            // Notify observers that the data has changed
            objectWillChange.send()
        } catch {
            self.error = error
            showErrorBanner = true
        }

        isLoadingData = false
    }

    func loadAppleHealth() {
        guard startDate <= endDate else {
            self.error = SDKError.healthDataError(message: "Invalid date range: Start date is after end date.")
            showErrorBanner = true
            return
        }
        
        isLoadingData = true
        let types = authorisationTypes
        resetElapsedTime()
        backgroundWorkStartTime = Date()
        updateElapsedTime()

        Task {
            do {
                try await healthDataService.loadHealthData(from: startDate, to: endDate, authorisationTypes: types)
                await MainActor.run {
                    isLoadingData = false
                    importFinished = true
                    backgroundWorkStartTime = nil
                    progressMessage = "exportingFiles".localized()
                    if exportAutomatically {
                        saveOutputToFiles()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingData = false
                    self.error = error
                    showErrorBanner = true
                }
            }
        }
    }

    func saveOutputToFiles() {
        isLoadingData = true
        isExporting = true
        backgroundWorkStartTime = Date()
        exportElapsedTime = 0
        numberOfExportedFiles = 0
        updateElapsedTime()

        backgroundExporter.loadSectionIds { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let sectionIds):
                    self.shareData(for: sectionIds, locally: false)
                case .failure(let error):
                    self.error = error
                    self.showErrorBanner = true
                    self.isLoadingData = false
                    self.isExporting = false
                }
            }
        }
    }

    func shareData(for parentIds: [String], locally: Bool) {
        isLoadingData = true

        backgroundExporter.shareAllData(for: parentIds, locally: locally, downloadHandler: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.numberOfExportedFiles = self.numberOfExportedFiles + 1
                default:
                    break
                }
            }
        }, completion: { [weak self] urls, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isLoadingData = false
                self.isExporting = false
                self.exportFinished = true
                self.backgroundWorkStartTime = nil

                if let error = error {
                    self.error = error
                    self.showErrorBanner = true
                } else if let urls = urls {
                    self.shareUrls = urls
                    self.numberOfExportedFiles = urls.count

                    if locally {
                        self.shareLocally = locally
                    } else {
                        self.finish()
                    }
                }
            }
        })
    }

    func startOver(_ completion: @escaping (() -> Void)) {
        isLoadingData = true

        error = nil
        successMessage = nil
        shareUrls = nil
        importFinished = false
        exportFinished = false
        backgroundWorkStartTime = nil

        Task.detached { [weak self] in
            guard let self = self else { return }

            do {
                try await persistenceActor.remove(predicate: #Predicate<HealthDataExportSection> { _ in true })
                try await persistenceActor.remove(predicate: #Predicate<HealthDataExportFile> { _ in true })
                try await persistenceActor.remove(predicate: #Predicate<HealthDataExportItem> { _ in true })

                await MainActor.run {
                    self.isLoadingData = false
                    completion()
                }
            } catch {
                print("Error clearing data: \(error)")
                await MainActor.run {
                    self.isLoadingData = false
                    completion()
                }
            }
        }
    }

    func onCancelTapped() {
        showFinishConfirmationDialog = false
    }

    func onProceedToFinishTapped() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onComplete?(.success((self.shareUrls ?? []).compactMap { $0.absoluteString }))
        }
    }

    // MARK: - Sections & data types to query

    func initToggles() {
        self.healthDataTypes = [
            HealthDataType(type: QuantityType.height),
            HealthDataType(type: QuantityType.bodyMass),
            HealthDataType(type: QuantityType.bodyTemperature),
            HealthDataType(type: QuantityType.bloodGlucose),
            HealthDataType(type: QuantityType.oxygenSaturation),
            HealthDataType(type: QuantityType.respiratoryRate),
            HealthDataType(type: QuantityType.heartRate),
            HealthDataType(type: QuantityType.bloodPressureSystolic),
            HealthDataType(type: QuantityType.bloodPressureDiastolic)
        ]
    }

    func toggleAllHealthDataTypes() {
        let newState = !allToggled
        for index in healthDataTypes.indices {
            healthDataTypes[index].isToggled = newState
        }
        allToggled = newState
    }

    func toggleSingleHealthDataType(at index: Int) {
        healthDataTypes[index].isToggled.toggle()
        updateAllToggledState()
    }

    private func updateAllToggledState() {
        allToggled = healthDataTypes.allSatisfy { $0.isToggled }
    }

    func updateSectionsAndItemCount() async {
        do {
            let fetchDescriptor = FetchDescriptor<HealthDataExportSection>(sortBy: [SortDescriptor(\.typeIdentifier)])
            let fetchedSections = try await persistenceActor.fetchData(predicate: fetchDescriptor.predicate, sortBy: fetchDescriptor.sortBy)

            let itemCount = try await persistenceActor.count(for: HealthDataExportItem.self)

            await MainActor.run {
                self.sections = fetchedSections
                self.totalItemsCount = itemCount
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    func toggleSectionExport(_ section: HealthDataExportSection) {
        Task {
            section.exportSelected.toggle()
            do {
                try await persistenceActor.save()
            } catch {
                print("Error saving section toggle: \(error)")
            }
        }
    }

    // MARK: - Timer

    func resetElapsedTime() {
        importElapsedTime = 0
        exportElapsedTime = 0
    }

    func updateElapsedTime() {
        guard let startTime = backgroundWorkStartTime else {
            return
        }

        let now = Date()
        if isExporting {
            exportElapsedTime = now.timeIntervalSince(startTime)
            print("Export Elapsed Time Updated: \(exportElapsedTime)")
        } 
        else if isLoadingData {
            importElapsedTime = now.timeIntervalSince(startTime)
            print("Import Elapsed Time Updated: \(importElapsedTime)")
        }
    }

    // MARK: - Private

    private func finish() {
        if let urls = shareUrls, !urls.isEmpty {
            onProceedToFinishTapped()
        }
        else if let error = error {
            onComplete?(.failure(error))
        }
        else {
            error = SDKError.unknown(message: "finishTitleUnsuccessful".localized())
            showErrorBanner = true
        }
    }
}

