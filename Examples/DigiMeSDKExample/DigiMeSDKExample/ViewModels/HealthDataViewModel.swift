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
import ModelsR5
import SwiftData

extension HealthDataViewModel: ExporterDelegate {
    func exporterDidUpdateProgress(_ progress: Int) {
        DispatchQueue.main.async {
            self.progressCounter = progress
        }
    }
}

class HealthDataViewModel: ObservableObject {
    @Published var progressCounter: Int = 0
    @Published var shareLocally = false
    @Published var isLoadingData = false
    @Published var dataFetchComplete = false
    @Published var showErrorBanner = false
    @Published var showSuccessBanner = false
    @Published var showFileList = false
    @Published var fileData: Data? = nil
    @Published var fileName: String? = nil
    @Published var fhirJson: JSON?
    @Published var storageFileList: [StorageFileInfo] = []
    @Published var elapsedTime: String?
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var downloadFileNameWithPath: String = ""
    @Published var cloudId: String = "" {
        didSet {
            UserPreferences.shared().setStorageId(identifier: cloudId, for: activeContract.identifier)
        }
    }
    @Published private var importRefresher: Timer?
    
    var isAuthorized: Bool {
        return userPreferences.getCredentials(for: activeContract.identifier) != nil
    }

    var isCloudCreated: Bool {
        return userPreferences.getStorageId(for: activeContract.identifier)?.isEmpty == false
    }

    var shareUrls: [URL]?
    var xmlReportURL: URL?
    var selectedParentIds: [String]?

    private let userPreferences = UserPreferences.shared()
    private let activeContract: DigimeContract

    private var modelContext: ModelContext
    private var modelContainer: ModelContainer
    private var measurements: [SelfMeasurement] = []
    private var digiMeService: DigiMe?
    private var linkedAccounts = [LinkedAccount]() {
        didSet {
            userPreferences.setLinkedAccounts(newAccounts: linkedAccounts, for: activeContract.identifier)
        }
    }
    private var intervalFormatter: DateComponentsFormatter {
        let fm = DateComponentsFormatter()
        fm.allowedUnits = [.hour, .minute, .second]
        fm.unitsStyle = .abbreviated
        fm.zeroFormattingBehavior = .pad
        return fm
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        activeContract = userPreferences.activeContract ?? Contracts.development
        cloudId = userPreferences.getStorageId(for: activeContract.identifier) ?? ""
        initialiseClient()
    }

    // MARK: - Init

    private func initialiseClient() {
        self.linkedAccounts = self.userPreferences.getLinkedAccounts(for: self.activeContract.identifier)
        do {
            let config = try Configuration(appId: self.activeContract.appId, contractId: self.activeContract.identifier, privateKey: self.activeContract.privateKey, authUsingExternalBrowser: true, baseUrl: self.activeContract.baseURL, cloudBaseUrl: self.activeContract.storageBaseURL)
            self.digiMeService = DigiMe(configuration: config)
        }
        catch {
            fatalError("Fatal error during DigiMe client initialization.")
        }
    }

    // MARK: - Timer

    private func startUploadTimer() {
        isLoadingData = true
        let startTime = Date()
        importRefresher = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard
                let self = self,
                let elapsed = self.intervalFormatter.string(from: startTime.timeIntervalSinceNow) else {

                self?.elapsedTime = "Elapsed time: 0"
                return
            }

            self.elapsedTime = "Elapsed time: \(elapsed)"
            if selectedParentIds == nil || dataFetchComplete {
                self.stopTimer()
                stopLoader()
            }
        }
    }

    private func stopTimer() {
        importRefresher?.invalidate()
        importRefresher = nil
    }

    // MARK: - Control Handlers

    func start() {
        guard !isLoadingData else {
            return
        }

        elapsedTime = nil
        startUploadTimer()

        guard 
            let parentIds = selectedParentIds,
            let cloudId = userPreferences.getStorageId(for: activeContract.identifier) else {
            // skip data retreval
            return
        }

        let exporter = BackgroundExporter(modelContainer: modelContainer, delegate: self)
        exporter.shareAllData(for: parentIds, locally: false, downloadHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                self?.errorMessage = error.description
                self?.showErrorBanner.toggle()
            case .success(let file):
                self?.uploadFile(for: file, cloudId: cloudId)
            }

        }) { [weak self] _, error in
            self?.dataFetchComplete = true

            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.showErrorBanner = true
            }
        }
    }
    
    func startOver(_ completion: @escaping (() -> Void)) {
        isLoadingData = true
        stopTimer()
        elapsedTime = nil
        progressCounter = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            // try? self.modelContext.delete(model: HealthDataExportSection.self, where: NSPredicate(value: true), includeSubentities: false)
            try? self.modelContext.delete(model: HealthDataExportSection.self)
            try? self.modelContext.delete(model: HealthDataExportFile.self)
            try? self.modelContext.delete(model: HealthDataExportItem.self)

            self.stopLoader()
            completion()
        }
    }

    func loadAppleHealth(from: Date, to: Date, authorisationTypes: [QuantityType], completion: @escaping ((Error?) -> Void)) {
        isLoadingData = true
        HealthDataService(modelContainer: modelContainer).loadHealthData(from: from, to: to, authorisationTypes: authorisationTypes) { error in
            self.stopLoader()
            completion(error)
        }
    }

    func shareDataLocally(for parentIds: [String], completion: @escaping ((Error?) -> Void)) {
        isLoadingData = true
        elapsedTime = nil
        let exporter = BackgroundExporter(modelContainer: modelContainer, delegate: self)
        exporter.shareAllData(for: parentIds, locally: true) { [weak self] urls, error in
            self?.stopLoader()
            if let error = error {
                completion(error)
            }
            else if let urls = urls {
                self?.shareUrls = urls
                self?.shareLocally = true
                completion(nil)
            }
        }
    }

    func shareIndividualItem() {
        guard let fhirJson = self.fhirJson else {
            return
        }

        isLoadingData = true

        DispatchQueue.global(qos: .background).async {
            if let jsonData = try? JSONSerialization.data(withJSONObject: fhirJson, options: []) {
                self.saveFileLocally(fileData: jsonData, fileName: UUID().uuidString + ".json") { url in
                    DispatchQueue.main.async {
                        self.stopLoader()
                        guard let url = url else {
                            return
                        }

                        self.shareUrls = [url]
                        self.shareLocally = true
                    }
                }
            }
            else {
                self.stopLoader()
            }
        }
    }

    func share(_ data: Data, fileName: String) {
        isLoadingData = true
        saveFileLocally(fileData: data, fileName: fileName) { url in
            DispatchQueue.main.async {
                self.stopLoader()
                guard let url = url else {
                    return
                }

                self.shareUrls = [url]
                self.shareLocally = true
            }
        }
    }

    // MARK: - Home View Actions

    func createStorage() {
        isLoadingData = true
        digiMeService?.createProvisionalStorage { [weak self] result in
            self?.stopLoader()
            guard let self = self else {
                return
            }

            switch result {
            case .success(let storage):
                self.cloudId = storage.cloudId
            case .failure(let error):
                self.errorMessage = error.description
                self.showErrorBanner.toggle()
            }
        }
    }

    func downloadFile() {
        guard
            !cloudId.isEmpty else {
            errorMessage = "Cloud storage id is missing"
            showErrorBanner.toggle()
            return
        }

        let split = splitFilePath()
        guard
            !downloadFileNameWithPath.isEmpty,
            !split.fileName.isEmpty else {
            errorMessage = "Invalid file name"
            showErrorBanner.toggle()
            return
        }

        isLoadingData = true

        digiMeService?.downloadStorageFile(storageId: cloudId, fileName: split.fileName, path: split.path) { [weak self] result in
            self?.stopLoader()
            switch result {
            case .success(let response):
                print("File download is successful")
                self?.share(response, fileName: split.fileName)

            case .failure(let error):
                self?.errorMessage = error.description
                self?.showErrorBanner.toggle()
            }
        }
    }

    func deleteFile() {
        guard
            !cloudId.isEmpty else {
            errorMessage = "Cloud storage id is missing"
            showErrorBanner.toggle()
            return
        }

        let split = splitFilePath()
        guard
            !downloadFileNameWithPath.isEmpty,
            !split.fileName.isEmpty else {
            errorMessage = "Invalid file name"
            showErrorBanner.toggle()
            return
        }

        isLoadingData = true
        digiMeService?.deleteStorageFile(storageId: cloudId, fileName: split.fileName, path: split.path) { [weak self] result in
            self?.stopLoader()
            switch result {
            case .success:
                self?.successMessage = "Delete file succeed"
                self?.showSuccessBanner.toggle()

            case .failure(let error):
                self?.errorMessage = error.description
                self?.showErrorBanner.toggle()
            }
        }
    }

    func deleteFolder() {
        guard
            !cloudId.isEmpty else {
            errorMessage = "Cloud storage id is missing"
            showErrorBanner.toggle()
            return
        }

        let split = splitFilePath()
        guard
            !downloadFileNameWithPath.isEmpty,
            !split.fileName.isEmpty else {
            errorMessage = "Invalid folder name"
            showErrorBanner.toggle()
            return
        }

        isLoadingData = true
        digiMeService?.deleteStorageFolder(storageId: cloudId, path: split.path) { [weak self] result in
            self?.stopLoader()
            switch result {
            case .success:
                self?.successMessage = "Delete folder succeed"
                self?.showSuccessBanner.toggle()

            case .failure(let error):
                self?.errorMessage = error.description
                self?.showErrorBanner.toggle()
            }
        }
    }

    func uploadFile(from url: URL?) {
        guard
            let url = url,
            url.startAccessingSecurityScopedResource(),
            let data = try? Data(contentsOf: url) else {
            self.errorMessage = "Error selecting file"
            self.showErrorBanner.toggle()
            return
        }

        guard
            !cloudId.isEmpty else {
            errorMessage = "Cloud storage id is missing"
            showErrorBanner.toggle()
            return
        }

        isLoadingData = true
        digiMeService?.uploadStorageFile(storageId: cloudId, fileName: url.lastPathComponent, data: data) { [weak self] result in
            self?.stopLoader()
            switch result {
            case .success:
                self?.successMessage = "Upload file succeed"
                self?.showSuccessBanner.toggle()

            case .failure(let error):
                self?.errorMessage = error.description
                self?.showErrorBanner.toggle()
            }
        }
    }

    func fileList() {
        guard
            !cloudId.isEmpty else {
            errorMessage = "Cloud storage id is missing"
            showErrorBanner.toggle()
            return
        }
        
        isLoadingData = true
        digiMeService?.readStorageFileList(storageId: cloudId, path: nil, recursive: true) { [weak self] result in
            self?.stopLoader()
            switch result {
            case .success(let fileList):
                self?.storageFileList = fileList.files ?? []
                self?.showFileList = true

            case .failure(let error):
                self?.errorMessage = error.description
                self?.showErrorBanner.toggle()
            }
        }
    }

    // MARK: - Private

    private func stopLoader() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.stopLoader()
            }
            return
        }

        isLoadingData = false
    }

    private func uploadFile(for item: HealthDataExportFileHandler, cloudId: String) {
        DispatchQueue.global(qos: .default).async {
            self.updateState(for: item.id, to: .uploading)
            self.digiMeService?.uploadStorageFile(storageId: cloudId, fileName: item.fileName, data: item.data, path: "apple-health") { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.updateState(for: item.id, to: .uploaded)
                    case .failure(_):
                        self?.updateState(for: item.id, to: .error)
                    }
                }
            }
        }
    }

    /// Updates the state of a HealthDataExportFile item asynchronously.
    func updateState(for itemId: UUID, to newState: UploadState) {
        DispatchQueue.global(qos: .default).async {
            let context = ModelContext(self.modelContainer)
            let descriptor = FetchDescriptor<HealthDataExportFile>(predicate: #Predicate<HealthDataExportFile> { $0.id == itemId })

            if let fileToUpdate = try? context.fetch(descriptor).first {
                fileToUpdate.uploadState = newState.rawValue
                try? context.save()
            }
        }
    }

    // MARK: - Utilities

    private func mockMedmijAccount() -> DigiMeCore.Source? {
        guard let url = Bundle.main.url(forResource: "medmij-disco3", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url),
              let source = try? JSONDecoder().decode(DigiMeCore.Source.self, from: jsonData) else {
            return nil
        }

        return source
    }

    func saveFileLocally(fileData: Data, fileName: String, completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            do {
                try fileData.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(fileURL)
                }
            } 
            catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error saving file locally: \(error)"
                    self.showErrorBanner.toggle()
                    completion(nil)
                }
            }
        }
    }

    private func readFile(named fileName: String) -> Data? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsURL.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }

    private func splitFilePath() -> (path: String, fileName: String) {
        let url = URL(fileURLWithPath: downloadFileNameWithPath)
        let fileName = url.lastPathComponent
        let path = url.deletingLastPathComponent().path

        // Handle the edge case where there's no path component
        let correctedPath = (path == "." || path.isEmpty) ? "/" : path

        return (correctedPath, fileName)
    }
}

extension FetchDescriptor {
    static var filesFetch: FetchDescriptor<HealthDataExportFile> {
        let descriptor = FetchDescriptor<HealthDataExportFile>(
            predicate: #Predicate<HealthDataExportFile> { $0.uploadState != 3 && $0.uploadState != 4 },
            sortBy: [
                SortDescriptor(\HealthDataExportFile.typeIdentifier)
            ]
        )
        return descriptor
    }
}
