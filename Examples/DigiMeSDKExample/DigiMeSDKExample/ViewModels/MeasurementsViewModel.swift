//
//  MeasurementsViewModel.swift
//  DigiMeSDKExample
//
//  Created on 01/07/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeCore
import DigiMeHealthKit
import DigiMeSDK
import Foundation
import ModelsR5
import SwiftData

@MainActor
class MeasurementsViewModel: ObservableObject {
    @Published var progressCounter: Int = 0
    @Published var shareLocally = false
    @Published var sharePortability = false
    @Published var isLoadingData = false
//    @Published var sections: [HealthDataExportSection] = []
    @Published var fhirJson: JSON?

    var isAuthorized: Bool {
        return userPreferences.getCredentials(for: userPreferences.activeContract?.identifier ?? Contracts.development.identifier) != nil
    }

    var shareUrls: [URL]?
    var xmlReportURL: URL?

    private let userPreferences = UserPreferences.shared()
    private let activeContract: DigimeContract

    private var modelContext: ModelContext
    private var modelContainer: ModelContainer

    private var measurements: [SelfMeasurement] = []
    private var shareIds: [String] = []
    private var digiMeService: DigiMe?
    private var retryAfter: Date?
    private var fetchDescriptor: FetchDescriptor<SelfMeasurement> {
        let descriptor = FetchDescriptor<SelfMeasurement>(
            sortBy: [
                .init(\.createdDate)
            ]
        )
        return descriptor
    }
    private var linkedAccounts = [LinkedAccount]() {
        didSet {
            userPreferences.setLinkedAccounts(newAccounts: linkedAccounts, for: userPreferences.activeContract?.identifier ?? Contracts.development.identifier)
        }
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        activeContract = userPreferences.activeContract ?? Contracts.development
        initialiseClient()
    }

    // MARK: - Database Context
    
    func addMeasurement(_ measurement: SelfMeasurement) {
        self.modelContext.insert(measurement)
    }

    func deleteMeasurement(at offsets: IndexSet) {
        for index in offsets {
            let destination = self.measurements[index]
            self.modelContext.delete(destination)
        }
    }

    func delete(measurement: SelfMeasurement) {
        self.modelContext.delete(measurement)
    }
    
    func save(from startDate: Date, to endDate: Date, locally: Bool, completion: @escaping (Error?) -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.save(from: startDate, to: endDate, locally: locally, completion: completion)
            }
            return
        }

        if let measurementsToSave = try? modelContext.fetch(fetchDescriptor) {
            // Filter measurements based on date range
            let filteredMeasurements = measurementsToSave.filter { measurement in
                let calendar = Calendar.current
                // Normalize dates to the start of the day for comparison
                let startOfDayForDate = calendar.startOfDay(for: measurement.createdDate)
                let startOfDayForStartDate = calendar.startOfDay(for: startDate)
                let startOfDayForEndDate = calendar.startOfDay(for: endDate)
                return startOfDayForDate >= startOfDayForStartDate && startOfDayForDate <= startOfDayForEndDate
            }

            // Map filtered measurements to entries
            let entries = filteredMeasurements.map { measurement -> ObservationEntry in
                return ObservationEntry(resource: measurement.fhirObservation, request: ObservationRequest(method: "POST", url: "Observation"), fullUrl: measurement.fullUrl)
            }

            let bundle = FHIRBundle(resourceType: "Bundle", type: "batch", entry: entries)

            let encoder = JSONEncoder()
            if locally {
                encoder.outputFormatting = .withoutEscapingSlashes
            }

            if
                let data = try? encoder.encode(bundle),
                let url = saveToDocumentDirectory(data: data) {
                shareUrls = [url]
                shareIds = entries.compactMap { $0.resource.identifier?.first?.value }
                assert(Thread.isMainThread, "This code should be on the main thread!")
                shareLocally = locally
                completion(nil)
            }
            else {
                completion(SDKError.unknown(message: "Measurments save has failed. Encoding error."))
            }
        }
        else {
            completion(SDKError.unknown(message: "Measurments save has failed. Error during fetch"))
        }
    }

    // MARK: - Portability Report

    func loadPortabilityReport(from: Date, to: Date, completion: @escaping ((Error?) -> Void)) {
        isLoadingData = true
        guard let accountCredentials = userPreferences.getCredentials(for: userPreferences.activeContract?.identifier ?? Contracts.development.identifier) else {
            authenticateAndLoadReport(from: from, to: to, completion: completion)
            return
        }

        exportPortabilityReport(from: from, to: to, accountCredentials: accountCredentials, completion: completion)
    }

    // MARK: - Share Self Measurements

    func shareMeasurements(from: Date, to: Date, completion: @escaping ((Error?) -> Void)) {
        isLoadingData = true
        beginPushAuthorization { [weak self] accountId, accountName, error in
            guard
                let self = self,
                error == nil else {

                    self?.isLoadingData = false
                    completion(error)
                    return
                }

            if
                let accountId = accountId,
                let accountName = accountName,
                let path = self.shareUrls?.first?.path,
                !self.shareIds.isEmpty {

                self.pushSelfMeasurements(accountId: accountId, accountName: accountName, ids: shareIds, payloadUrlString: path) { [weak self] error in

                    self?.isLoadingData = false
                    completion(error)
                }
            }
            else {
                self.isLoadingData = false
                completion(SDKError.unknown(message: "An error occured pushing your data, please try again later"))
            }
        }
    }

//     MARK: - Apple Health

//    func loadAppleHealth(from: Date, to: Date, authorisationTypes: [QuantityType], completion: @escaping ((Error?) -> Void)) {
//        isLoadingData = true
//        HealthDataService(modelContainer: modelContainer).loadHealthData(from: from, to: to, authorisationTypes: authorisationTypes) { error in
//            DispatchQueue.main.async {
//                self.isLoadingData = false
//                completion(error)
//            }
//        }
//    }
    
//    func loadAppleHealth2(from startDate: Date, to endDate: Date, authorisationTypes: [QuantityType], completion: @escaping ((Error?) -> Void)) {
//        isLoadingData = true
//        let dateRanges = createDateRanges(from: startDate, to: endDate)
//
//        // Dictionary to hold merged results
//        var allResults = [String: HealthDataExportSection]()
//
//        // Create a serial queue to manage access to allResults
//        let resultsQueue = DispatchQueue(label: "com.yourapp.resultsQueue")
//
//        let group = DispatchGroup()
//
//        for range in dateRanges {
//            group.enter()
//            HealthDataService().loadHealthData(from: range.start, to: range.end, authorisationTypes: authorisationTypes) { results, error in
//                resultsQueue.async {
//                    guard let results = results else {
//                        completion(error ?? SDKError.healthDataError(message: "Error loading data"))
//                        group.leave()
//                        return
//                    }
//
//                    // Merge the batch results
//                    for section in results {
//                        if let existingSection = allResults["\(section.type.type)"] {
//                            var newItem = HealthDataExportSection(type: existingSection.type, items: existingSection.items, elapsedInterval: existingSection.elapsedInterval)
//                            newItem.items.append(contentsOf: section.items)
//                            newItem.elapsedInterval = max(section.elapsedInterval, newItem.elapsedInterval)
//                            allResults["\(section.type.type)"] = newItem
//                        }
//                        else {
//                            allResults["\(section.type.type)"] = section
//                        }
//                    }
//
//                    group.leave()
//                }
//            }
//        }
//
//        group.notify(queue: .main) { [weak self] in
//            self?.isLoadingData = false
//
//            // Since final aggregation and UI updates are performed,
//            // make sure to switch back to the main queue
//            DispatchQueue.main.async {
//                // Convert the dictionary back to an array for the final result
//                let finalSections = Array(allResults.values)
//                self?.sections = finalSections
//
//                completion(nil)
//            }
//        }
//    }
//
//    func createDateRanges(from startDate: Date, to endDate: Date) -> [(start: Date, end: Date)] {
//        var ranges = [(start: Date, end: Date)]()
//        var start = startDate
//        let calendar = Calendar.current
//
//        while start < endDate {
//            let end = calendar.date(byAdding: .month, value: 12, to: start) ?? endDate
//            ranges.append((start, min(end, endDate)))
//            start = end
//        }
//
//        return ranges
//    }

//    func toggleItemSelected(at indexPath: IndexPath) {
//        sections[indexPath.section].items[indexPath.row].isSelected.toggle()
//    }

//    func shareAllData2(_ identifiers: [String]) {
//        isLoadingData = true
//
//        DispatchQueue.global(qos: .background).async {
//            var itemsToExport: [String] = []
//            identifiers.forEach { identifier in
//                let descriptor = FetchDescriptor<HealthDataExportItem>(predicate: #Predicate { $0.parentId == identifier })
//                let items = (try? self.modelContext.fetch(descriptor)) ?? []
//                let data = items.compactMap { $0.jsonData }
//                data.forEach { jsonData in
//                    let res = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON
//                    itemsToExport.append(res?.stringValue?.withoutBackslashes ?? "")
//                }
//            }
//
//            if 
//                let jsonData = try? JSONSerialization.data(withJSONObject: itemsToExport, options: [.withoutEscapingSlashes]) {
//                DispatchQueue.main.async {
//                    if let url = self.saveToDocumentDirectory(data: jsonData) {
//                        self.shareUrls = [url]
//                        self.shareLocally = true
//                        self.isLoadingData = false
//                    }
//                }
//            }
//            else {
//                DispatchQueue.main.async {
//                    self.isLoadingData = false
//                }
//            }
//        }
//    }

//    func shareAllData3(_ identifiers: [String]) {
//        isLoadingData = true
//        let exporter = BackgroundExporter(modelContainer: modelContainer, delegate: self)
//        exporter.shareAllData(identifiers) { [weak self] urls, error in
//            self?.isLoadingData = false
//
//            if let error = error {
//                print(error)
//            }
//            else if let urls = urls {
//                self?.shareUrls = urls
//                self?.shareLocally = true
//            }
//        }
//    }

//    func shareAllData() {
//        isLoadingData = true
//        let data = self.sections.flatMap { $0.items }.map { $0.json }
//
//        DispatchQueue.global(qos: .background).async {
//            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) {
//                DispatchQueue.main.async {
//                    if let url = self.saveToDocumentDirectory(data: jsonData) {
//                        self.shareUrl = [url]
//                        self.shareLocally = true
//                        self.isLoadingData = false
//                    }
//                }
//            }
//            else {
//                DispatchQueue.main.async {
//                    self.isLoadingData = false
//                }
//            }
//        }
//    }

    func shareIndividualItem() {
        guard let fhirJson = self.fhirJson else {
            return
        }

        isLoadingData = true

        DispatchQueue.global(qos: .background).async {
            if let jsonData = try? JSONSerialization.data(withJSONObject: fhirJson, options: []) {
                DispatchQueue.main.async {
                    self.isLoadingData = false

                    guard let url = self.saveToDocumentDirectory(data: jsonData) else {
                        return
                    }

                    self.shareUrls = [url]
                    self.shareLocally = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.isLoadingData = false
                }
            }
        }
    }

    // MARK: - Init

    private func initialiseClient() {
        DispatchQueue.main.async {
            self.linkedAccounts = self.userPreferences.getLinkedAccounts(for: self.activeContract.identifier)
            do {
                let config = try Configuration(appId: self.activeContract.appId, contractId: self.activeContract.identifier, privateKey: self.activeContract.privateKey, authUsingExternalBrowser: true, baseUrl: self.activeContract.baseURL, cloudBaseUrl: self.activeContract.storageBaseURL)
                self.digiMeService = DigiMe(configuration: config)
            }
            catch {
                fatalError("Fatal error during DigiMe client initialization.")
            }
        }
    }

    // MARK: - Push Self-Measurements

    private func beginPushAuthorization(completion: @escaping((String?, String?, Error?) -> Void)) {
        authoriseToPush { error in
            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            self.retrieveAuthorizedAccountIdForPush { accountId, accountName, error in
                completion(accountId, accountName, error)
            }
        }
    }

    private func retrieveAuthorizedAccountIdForPush(completion: @escaping((String?, String?, Error?) -> Void)) {
        guard
            let credentials = userPreferences.getCredentials(for: activeContract.identifier),
            // Check if already pushed data before and we have account reference.
            let reference = credentials.accountReference else {

            // We start from the beginning. No data was pushed before.
            self.beginPushAuthorization(completion: completion)
            return
        }

        // Reference is just a hash of the account entity id.
        // We have to pull all available accounts from the library and pick the right one.
        getAccountIdForPushIfNotExpired(reference: reference) { [weak self] accountId, accountName, error in
            if let accountId = accountId {
                completion(accountId, accountName, error)
            }
            else {
                self?.beginPushAuthorization(completion: completion)
            }
        }
    }

    private func getAccountIdForPushIfNotExpired(reference: String, completion: @escaping((String?, String?, Error?) -> Void)) {
        getAccounts { result, error in
            let validAccount = result?.first { accountData in
                if let accessTokenExpiresAt = accountData.accessTokenStatus?.expiresAt {
                    return accountData.reference == reference &&
                    accountData.accessTokenStatus?.authorized == true &&
                    Date(timeIntervalSince1970: accessTokenExpiresAt / 1000) > Date()
                }
                return false
            }

            completion(validAccount?.id, validAccount?.serviceProviderName, error)
        }
    }

    private func getAccounts(with completion: @escaping (([SourceAccountData]?, Error?) -> Void)) {
        guard let credentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            completion(nil, SDKError.unknown(message: "Attempting to read data with invalid credentials"))
            return
        }

        digiMeService?.readAccounts(credentials: credentials) { [weak self] newOrRefreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self?.activeContract.identifier)

            switch result {
            case .success(let accounts):
                completion(accounts, nil)

            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    private func authoriseToPush(completion: @escaping((Error?) -> Void)) {
        digiMeService?.authorizeServiceToPushData(credentials: userPreferences.getCredentials(for: activeContract.identifier)) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.userPreferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.userPreferences.activeContract?.identifier)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    private func pushSelfMeasurements(accountId: String, accountName: String, ids: [String], payloadUrlString: String, completion: @escaping((Error?) -> Void)) {
        guard let accountCredentials = userPreferences.getCredentials(for: userPreferences.activeContract?.identifier ?? Contracts.development.identifier) else {
            completion(SDKError.unknown(message: "Attempting to read data before authorizing contract"))
            return
        }

        let url = URL(fileURLWithPath: payloadUrlString)

        guard let payload = try? Data(contentsOf: url) else {
            completion(SDKError.unknown(message: "Error opening payload content from provided URL"))
            return
        }

        digiMeService?.pushDataToProvider(payload: payload, accountId: accountId, standard: "fhir", version: "stu3", credentials: accountCredentials) { [weak self] newOrRefreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self?.userPreferences.activeContract?.identifier ?? Contracts.development.identifier)
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let response):
                self?.saveReceipt(accountName: accountName, shareDate: Date(), ids: ids)
                print(String(data: response, encoding: .utf8) as Any)
                completion(nil)
            }
        }
    }

    private func authenticateAndLoadReport(from: Date, to: Date, completion: @escaping ((Error?) -> Void)) {
        guard let service = mockMedmijAccount() else {
            completion(SDKError.unknown(message: "Error initialization Medmij service account"))
            return
        }

        isLoadingData = true
        digiMeService?.authorize(serviceId: service.id, readOptions: service.options) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.linkedAccounts.append(LinkedAccount(source: service))
                self.userPreferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.userPreferences.activeContract?.identifier ?? Contracts.development.identifier)
                self.exportPortabilityReport(from: from, to: to, accountCredentials: newOrRefreshedCredentials, completion: completion)

            case.failure(let error):
                self.isLoadingData = false
                completion(error)
            }
        }
    }

    private func exportPortabilityReport(from: Date, to: Date, accountCredentials: Credentials, completion: @escaping ((Error?) -> Void)) {
        isLoadingData = true
        digiMeService?.exportPortabilityReport(for: "medmij", format: "xml", from: from.timeIntervalSince1970, to: to.timeIntervalSince1970, credentials: accountCredentials) { [weak self] refreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.userPreferences.activeContract?.identifier)
            switch result {
            case .success(let data):
                let fileName = "Portability_report_\(Date().description).xml"
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: fileName) { url in
                    guard let url = url else {
                        completion(SDKError.unknown(message: "An error occured storing '\(fileName)' file"))
                        return
                    }
                    self?.xmlReportURL = url
                    completion(nil)
                    self?.isLoadingData = false
                    self?.sharePortability = true
                }

            case .failure(let error):
                self?.isLoadingData = false
                completion(error)
            }
        }
    }

    private func saveReceipt(accountName: String, shareDate: Date, ids: [String]) {
        // TODO: Implement this function
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

    private func saveToDocumentDirectory(data: Data) -> URL? {
        let filename = UUID().uuidString + ".json"
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename) else {
            return nil
        }

        try? data.write(to: url)
        return url
    }
}
