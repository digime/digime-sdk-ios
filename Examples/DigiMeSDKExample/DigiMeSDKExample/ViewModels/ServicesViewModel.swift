//
//  ServicesViewModel.swift
//  DigiMeSDKExample
//
//  Created on 21/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import Foundation
import SwiftData
import SwiftUI

enum ConnectSourceViewState {
    case none, sources, sampleData
}

class ServicesViewModel: ObservableObject {
    @Published var activeContract: DigimeContract = Contracts.integration {
        didSet {
            updateContract(activeContract)
        }
    }

    @Published var sourceSections: [SourceSection] = []
    @Published var sourceSampleDataSections: [SourceSection] = []
    @Published var serviceSections: [ServiceSection] = [] {
        didSet {
            if let data = try? serviceSections.encoded(dateEncodingStrategy: .millisecondsSince1970) {
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "serviceSections")
            }
        }
    }
    @Published var sampleDataSections: [ServiceSection] = [] {
        didSet {
            if let data = try? sampleDataSections.encoded(dateEncodingStrategy: .millisecondsSince1970) {
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "sampleDataSections")
            }
        }
    }
    @Published var linkedAccounts = [LinkedAccount]() {
        didSet {
            userPreferences.setLinkedAccounts(newAccounts: linkedAccounts, for: activeContract.identifier)
        }
    }
    @Published var sourceItemsUpdateTrigger = false
    @Published var totalNumberOfItems: Int = 0
    @Published var totalNumberOfSampleDataItems: Int = 0
    @Published var sampleDatasets: [String: SampleDataset]?
    @Published var xmlReportURL: URL?
    @Published var isLoadingData = false
    @Published var shouldDisplaySourceSelector = false
    @Published var shouldDisplayScopeFilterView = false
    @Published var shouldDisplayShareSheet = false
    @Published var shouldDisplayCancelButton = false {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var sourceSelectionCompletionHandler: ((Source, String?) -> Void)?

    var onShowSampleDataSelectorChanged: ((Bool) -> Void)?
    var onShowSampleDataErrorChanged: ((Bool) -> Void)?
    var onProceedSampleDatasetChanged: ((Bool) -> Void)?
    var modelContainer: ModelContainer
    var isAuthorized: Bool {
        return userPreferences.getCredentials(for: activeContract.identifier) != nil
    }

    private let loggingService: LoggingServiceProtocol
    private let userPreferences = UserPreferences.shared()

    private var digiMeService: DigiMe?
    private var retryAfter: Date?

    init(loggingService: LoggingServiceProtocol, modelContainer: ModelContainer) {
        self.loggingService = loggingService
        self.modelContainer = modelContainer

        do {
            if let contract = Contracts.all.first(where: { $0.identifier == userPreferences.activeContract?.identifier }) {
                activeContract = contract
            }
            else {
                activeContract = Contracts.integration
            }

            linkedAccounts = userPreferences.getLinkedAccounts(for: userPreferences.activeContract?.identifier ?? Contracts.development.identifier)

            let sdkConfig = try Configuration(appId: activeContract.appId, contractId: activeContract.identifier, privateKey: activeContract.privateKey, authUsingExternalBrowser: true, baseUrl: activeContract.baseURL, cloudBaseUrl: activeContract.storageBaseURL)
            digiMeService = DigiMe(configuration: sdkConfig)
        }
        catch {
            logErrorMessage("Unable to configure digi.me SDK: \(error)")
        }
        
        updateCounter()
    }

    func authorizeSelectedService() {
        guard !isLoadingData else {
            return
        }
        
        chooseSource { [weak self] selectedSource, sampleDataSetId in
            guard let selectedSource = selectedSource else {
                return
            }
            
            if let sampleDataSetId = sampleDataSetId {
                self?.authenticateAndFetchData(source: selectedSource, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: true)
            }
            else {
                self?.authenticateAndFetchData(source: selectedSource)
            }
        }
    }

    func reauthorizeAccount(connectedAccount: LinkedAccount) {
        guard !isLoadingData else {
            return
        }
        
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            isLoadingData = false
            logWarningMessage("Current contract must be authorized first.")
            return
        }
        
        guard let accountId = connectedAccount.sourceAccount?.id else {
            isLoadingData = false
            logWarningMessage("Error extracting account id.")
            return
        }
        
        isLoadingData = true
        shouldDisplayCancelButton = true
        digiMeService?.reauthorizeAccount(accountId: accountId, credentials: accountCredentials) { [weak self] refreshedCredentials, reauthResult in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)
            self?.shouldDisplayCancelButton = false
            switch reauthResult {
            case .success:
                self?.fetchData(credentials: refreshedCredentials)
                if let index = self?.linkedAccounts.firstIndex(where: { $0 == connectedAccount }) {
                    self?.linkedAccounts[index].requiredReauth = false
                }
            case .failure(let error):
                self?.isLoadingData = false
                self?.logErrorMessage("Reauthorizing \(connectedAccount.source.name) failed: \(error)")
            }
        }
    }

    func addNewSource() {
        guard !isLoadingData else {
            return
        }

        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            isLoadingData = false
            logWarningMessage("Current contract must be authorized first.")
            return
        }

        chooseSource { [weak self] selectedSource, sampleDataSetId in
            guard let selectedSource = selectedSource else {
                return
            }

            if let sampleDataSetId = sampleDataSetId {
                self?.addAccountAndFetchData(source: selectedSource, credentials: accountCredentials, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: true)
            }
            else {
                self?.addAccountAndFetchData(source: selectedSource, credentials: accountCredentials)
            }
        }
    }

    func reloadServiceData(readOptions: ReadOptions? = nil) {
        if let retry = retryAfter, retry > Date() {
            logWarningMessage("Data refresh blocked. \(retry.timeIntervalRetryDescription()).")
            return
        }

        guard !isLoadingData else {
            return
        }
        
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            isLoadingData = false
            logWarningMessage("Current contract must be authorized first.")
            return
        }

        guard accountCredentials.token.refreshToken.isValid else {
            isLoadingData = false
            logWarningMessage("Authentication credentials have expired. Please start over.")
            return
        }

        isLoadingData = true

        requestDataFetch(credentials: accountCredentials, readOptions: readOptions) { [weak self] refreshedCredentials in
            self?.fetchAccounts(credentials: refreshedCredentials) { newOrRefresgedCredentials in
                self?.fetchServiceData(credentials: newOrRefresgedCredentials, readOptions: readOptions)
            }
        }
    }
    
    func presentActionSheet(withDatasets datasets: [String: SampleDataset], on viewController: UIViewController, completion: @escaping (String) -> Void) {
        let actionSheet = UIAlertController(title: "Select Sample Dataset", message: nil, preferredStyle: .actionSheet)

        for (_, dataset) in datasets {
            let action = UIAlertAction(title: dataset.name, style: .default) { _ in
                completion(dataset.name)
            }
            actionSheet.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        viewController.present(actionSheet, animated: true)
    }

    func fetchDemoDataSetsInfoForSource(source: Source) {
        guard !isLoadingData else {
            return
        }

        isLoadingData = true
        digiMeService?.fetchDemoDataSetsInfoForService(serviceId: "\(source.id)") { [weak self] result in
            self?.isLoadingData = false
            switch result {
            case .success(let datasets):
                self?.sampleDatasets = datasets
                if datasets.keys.count > 1 {
                    self?.handleSampleDataSelectorChange()
                }
                else if datasets.keys.count == 1 {
//                    if self?.isAuthorized {
//                        self?.addNewService()
//                    }
//                    else {
//                        self?.authenticateAndFetchData(service: service, sampleDataSetId: datasets.first?.key, sampleDataAutoOnboard: true)
//                    }
                    self?.handleProceedSampleDatasetChange()
                }
                else {
                    self?.handleSampleDataErrorChange()
                }
            case .failure(let error):
                self?.logErrorMessage("Unable to retrieve sample datasets details: \(error)")
                self?.handleSampleDataErrorChange()
            }
        }
    }

    func handleSampleDataSelectorChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.onShowSampleDataSelectorChanged?(true)
        }
    }
    
    func handleSampleDataErrorChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.onShowSampleDataErrorChanged?(true)
        }
    }
    
    func handleProceedSampleDatasetChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.onProceedSampleDatasetChanged?(true)
        }
    }
    
    func displayContractDetails() {
        guard !isLoadingData else {
            return
        }
        
        isLoadingData = true
        digiMeService?.contractDetails { [weak self] result in
            self?.isLoadingData = false
            switch result {
            case .success(let certificate):
                self?.logMessage("Contract details:", attachmentType: LogEntry.AttachmentType.json, attachment: try? certificate.encoded())
            case .failure(let error):
                self?.logErrorMessage("Unable to retrieve contract details: \(error)")
            }
        }
    }

    func removeUser() {
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            logWarningMessage("Contract must be authorized first.")
            return
        }

        guard accountCredentials.token.refreshToken.isValid else {
            reset()
            return
        }
        
        isLoadingData = true
        digiMeService?.deleteUser(credentials: accountCredentials) { [weak self] refreshedCredentials, result in
            self?.isLoadingData = false

            switch result {
            case .success:
                self?.userPreferences.clearCredentials(for: self?.activeContract.identifier)
                self?.resetLogs()
                self?.linkedAccounts = []
                self?.logMessage("Your user entry and the library deleted successfully")
            case .failure(let error):
                self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)
                self?.logErrorMessage(error.description)
            }
        }
    }

    func deleteAccount(_ account: LinkedAccount) {
        guard
            let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier),
            let accountId = account.sourceAccount?.id else {
            
            logWarningMessage("Contract must be authorized first.")
            return
        }

        isLoadingData = true
        digiMeService?.deleteAccount(accountId: accountId, credentials: accountCredentials) { [weak self] refreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)
            self?.isLoadingData = false

            switch result {
            case .success:
                self?.linkedAccounts.remove(object: account)
                self?.logMessage("User account deleted successfully")
            case .failure(let error):
                self?.logErrorMessage(error.description)
            }
        }
    }

    func withdrawConsent(for account: LinkedAccount) {
        guard
            let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier),
            let accountId = account.sourceAccount?.id else {

            logWarningMessage("Contract must be authorized first.")
            return
        }

        isLoadingData = true
        shouldDisplayCancelButton = true
        digiMeService?.getRevokeAccountPermissionUrl(for: accountId, credentials: accountCredentials) { [weak self] refreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)
            self?.shouldDisplayCancelButton = false
            self?.isLoadingData = false

            switch result {
            case .success:
                self?.logMessage("Service account access revoked successfully")
                self?.fetchData(credentials: refreshedCredentials)
            case .failure(let error):
                self?.logErrorMessage(error.description)
            }
        }
    }

    func exportPortabilityReport(for serviceTypeName: String, format: String, from: TimeInterval, to: TimeInterval) {
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            isLoadingData = false
            logWarningMessage("Contract must be authorized first.")
            return
        }

        isLoadingData = true
        digiMeService?.exportPortabilityReport(for: serviceTypeName, format: format, from: from, to: to, credentials: accountCredentials) { [weak self] refreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)
            self?.isLoadingData = false
            switch result {
            case .success(let data):
                let fileName = "Report_\(serviceTypeName)_\(Date().description).\(format)"
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: fileName) { url in
                    guard let url = url else {
                        self?.logErrorMessage("An error occured storing '\(fileName)' file")
                        return
                    }
                    self?.xmlReportURL = url
                    self?.logMessage("Report successfully shared.")
                    self?.shouldDisplayShareSheet = true
                }

            case .failure(let error):
                self?.logErrorMessage("Error requesting data export: \(error)")
            }
        }
    }

    func stopFetchingData() {
        isLoadingData = false
        shouldDisplayCancelButton = false
        logWarningMessage("Data retrieval was cancelled by the user.")
    }

    // MARK: - Private

    private func updateCounter() {
        updateApprovedCounter()
        updateSampleDataCounter()
        DispatchQueue.main.async {
            self.sourceItemsUpdateTrigger.toggle()
        }
    }

    private func updateApprovedCounter() {
        let contractId = activeContract.identifier
        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = #Predicate<SourceItem> { item in
                item.contractId == contractId
                && item.sampleData == false
            }

            let descriptor = FetchDescriptor<SourceItem>(predicate: predicate)
            let total = (try? ModelContext(self.modelContainer).fetchCount(descriptor)) ?? 0
            DispatchQueue.main.async {
                self.totalNumberOfItems = total
            }
        }
    }

    private func updateSampleDataCounter() {
        let contractId = activeContract.identifier
        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = #Predicate<SourceItem> { item in
                item.contractId == contractId
            }

            let descriptor = FetchDescriptor<SourceItem>(predicate: predicate)
            let total = (try? ModelContext(self.modelContainer).fetchCount(descriptor)) ?? 0
            DispatchQueue.main.async {
                self.totalNumberOfSampleDataItems = total
            }
        }
    }

    private func updateContract(_ contract: DigimeContract) {
        DispatchQueue.main.async {
            self.linkedAccounts = self.userPreferences.getLinkedAccounts(for: contract.identifier)
            self.userPreferences.activeContract = contract
            do {
                let config = try Configuration(appId: contract.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true, baseUrl: contract.baseURL, cloudBaseUrl: contract.storageBaseURL)
                self.digiMeService = DigiMe(configuration: config)
            }
            catch {
                self.logErrorMessage("Unable to configure digi.me SDK: \(error)")
            }
        }
    }

    private func authenticateAndFetchData(source: Source, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil) {
        isLoadingData = true
        shouldDisplayCancelButton = true
        
        let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier)
        let storageId = userPreferences.getStorageId(for: activeContract.identifier)
        digiMeService?.authorize(credentials: accountCredentials, serviceId: source.id, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataAutoOnboard, readOptions: source.options, storageId: storageId) { [weak self] result in
            self?.shouldDisplayCancelButton = false

            switch result {
            case .success(let newOrRefreshedCredentials):
                self?.logMessage("Contract authorised successfully for service id: \(source.id)")
                self?.linkedAccounts.append(LinkedAccount(source: source))
                self?.userPreferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self?.activeContract.identifier)
                self?.fetchData(credentials: newOrRefreshedCredentials, readOptions: source.options)

            case.failure(let error):
                self?.isLoadingData = false
                self?.logErrorMessage("Authorization failed: \(error)")
            }
        }
    }

    private func addAccountAndFetchData(source: Source, credentials: Credentials, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil) {
        shouldDisplayCancelButton = true
        digiMeService?.addService(identifier: source.id, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataSetId != nil, credentials: credentials) { [weak self] refreshedCredentials, addServiceResult in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)
            self?.shouldDisplayCancelButton = false
            switch addServiceResult {
            case .success:
                self?.linkedAccounts.append(LinkedAccount(source: source))
                self?.fetchData(credentials: refreshedCredentials, readOptions: source.options)

            case.failure(let error):
                self?.isLoadingData = false
                self?.logErrorMessage("Adding \(source.name) failed: \(error)")
            }
        }
    }

    private func chooseSource(completion: @escaping ((Source?, String?) -> Void)) {
        sourceSelectionCompletionHandler = completion

        withAnimation {
            self.shouldDisplaySourceSelector = true
        }

        let includeFields: [SourcesFieldList] = [
            // .address,
            .category,
            // .categoryTypeId,
            .categoryId,
            // .categoryJson,
            .categoryName,
            // .categoryReference,
            // .country,
            // .countryCode,
            // .countryId,
            // .countryJson,
            // .countryName,
            // .dynamic,
            .id,
            // .json,
            // .onboardable,
            .name,
            // .platform,
            // .platformId,
            // .platformJson,
            // .platformName,
            // .platformReference,
            // .providerId,
            // .publishedDate,
            .publishedStatus,
            // .reference,
            .resourceUrl,
            // .resourceMimetype,
            .service,
            // .serviceDynamic,
            .serviceId,
            // .serviceJson,
            // .serviceName,
            // .servicePublishedDate,
            .servicePublishedStatus,
            // .serviceReference,
            .serviceServiceTypeId,
            // .type,
            // .typeId,
            // .typeName,
            // .typeReference,
        ]

        let type = SourceTypeRequestFilter([.pull])
        let filter = SourceFilter(publishedStatus: [.approved, .sampledataonly], type: type)
        let query = SourcesQuery(search: nil, include: includeFields, filter: filter)
        let sort = SourcesSort(name: .asc)

        let payload = SourceRequestCriteria(limit: nil, offset: 0, sort: sort, query: query)

        digiMeService?.availableSources(filter: payload, resultQueue: .global(qos: .utility)) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let sourceInfo):
                self.logMessage("The Total Number of Sources: \(sourceInfo.total)")
                self.logMessage("Sources Fetch Limit: \(sourceInfo.limit)")
                self.logMessage("Sources Fetch Offset: \(sourceInfo.offset)")

                SourceImporter(modelContainer: self.modelContainer).populateSources(contractId: self.activeContract.identifier, sourceInfo: sourceInfo)
                updateCounter()

//              if let data = try? sourceInfo.encoded() {
//                 FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "sources.json")
//              }

                self.downloadSubsequentBatches(initialSourceInfo: sourceInfo, includeFields: includeFields, filter: filter, sort: sort)
            case .failure(let error):
                self.logErrorMessage("Unable to retrieve services: \(error)")
            }
        }
    }

    // MARK: - Private

    private func downloadSubsequentBatches(initialSourceInfo: SourcesInfo, includeFields: [SourcesFieldList], filter: SourceFilter, sort: SourcesSort) {
        let total = initialSourceInfo.total
        let batchSize = initialSourceInfo.limit
        guard total > batchSize else {
            self.logMessage("Finished downloading: Only one batch required or total sources less than batch size.")
            return
        }

        let remainingBatches = (total - batchSize) / batchSize + (!(total - batchSize).isMultiple(of: batchSize) ? 1 : 0)
        self.logMessage("Starting to download \(remainingBatches) subsequent batches.")

        for index in 0..<remainingBatches {
            let offset = (index + 1) * batchSize
            let subsequentPayload = SourceRequestCriteria(limit: nil, offset: offset, sort: sort, query: SourcesQuery(search: nil, include: includeFields, filter: filter))
            self.logMessage("Downloading batch \(index + 1) of \(remainingBatches); \(remainingBatches - (index + 1)) batches left.")
            fetchAndProcessBatch(payload: subsequentPayload, index: index)
        }

        self.logMessage("Download discovery sources completed. Batches to import: \(remainingBatches)")
    }

    private func fetchAndProcessBatch(payload: SourceRequestCriteria, index: Int) {
        digiMeService?.availableSources(filter: payload, resultQueue: .global(qos: .utility)) { [weak self] result in
            guard let self = self else {
                print("Download Subsequent Sources Interrupted")
                return
            }
            switch result {
            case .success(let sourceInfo):
//                if let data = try? sourceInfo.encoded() {
//                    FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "sources_\(index).json")
//                }

                SourceImporter(modelContainer: self.modelContainer).populateSources(contractId: self.activeContract.identifier, sourceInfo: sourceInfo)
                self.logMessage("Importing batch: \(index + 1)")
                updateCounter()

            case .failure(let error):
                self.logErrorMessage("Failed to retrieve subsequent batch: \(error)")
            }
        }
    }

    private func fetchData(credentials: Credentials, readOptions: ReadOptions? = nil) {
        fetchAccounts(credentials: credentials) { [weak self] updatedCredentials in
            self?.fetchServiceData(credentials: updatedCredentials, readOptions: readOptions)
        }
    }

    private func fetchAccounts(credentials: Credentials, completion: @escaping (Credentials) -> Void) {
        isLoadingData = true
        
        digiMeService?.readAccounts(credentials: credentials) { [weak self] refreshedCredentials, result in
            switch result {
            case .success(let accountDetails):
                self?.logMessage("Accounts info retrieved successfully")
                self?.addAccountDetails(accounts: accountDetails)
                completion(refreshedCredentials)
            case .failure(let error):
                if case .failure(.invalidSession) = result {
                    // Need to create a new session
                    self?.requestDataFetch(credentials: refreshedCredentials) { renewedCredentials in
                        self?.fetchAccounts(credentials: renewedCredentials, completion: completion)
                    }
                    return
                }
                
                self?.logErrorMessage("Error retrieving accounts: \(error)")
            }
        }
    }

    private func requestDataFetch(credentials: Credentials, readOptions: ReadOptions? = nil, completion: @escaping (Credentials) -> Void) {
        digiMeService?.requestDataQuery(credentials: credentials, readOptions: readOptions) { [weak self] refreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)

            switch result {
            case .success:
                completion(refreshedCredentials)
                
            case.failure(let error):
                self?.isLoadingData = false
                self?.logErrorMessage("Authorization failed: \(error)")
            }
        }
    }

    private func fetchServiceData(credentials: Credentials, readOptions: ReadOptions? = nil) {
        DispatchQueue.main.async {
            self.isLoadingData = true
        }
        
        digiMeService?.readAllFiles(credentials: credentials, readOptions: readOptions) { [weak self] result in
            switch result {
            case .success(let fileContainer):

                switch fileContainer.metadata {
                case .mapped(let metadata):
                    self?.logMessage("Downloaded mapped file \(fileContainer.identifier).", attachmentType: .jfs, attachment: fileContainer.data, metadataMapped: try? metadata.encoded())
                case .raw(let metadata):
                    self?.logMessage("Downloaded unmapped file \(fileContainer.identifier). File size: \(fileContainer.data.count) bytes.", attachmentType: LogEntry.mapped(mimeType: metadata.mimeType), attachment: fileContainer.data, metadataRaw: try? metadata.encoded())
                default:
                    self?.logErrorMessage("Error reading file 'Unexpected metadata'")
                }
                                
                if !fileContainer.data.isEmpty {
                    FilePersistentStorage(with: .documentDirectory).store(data: fileContainer.data, fileName: fileContainer.identifier)
                }
                
            case .failure(let error):
                self?.logErrorMessage("Error reading file: \(error)")
            }
        } completion: { [weak self] refreshedCredentials, result in
            self?.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self?.activeContract.identifier)

            self?.isLoadingData = false

            switch result {
            case .success(let fileList):
                self?.updateReauthStatus(fileList.status.details ?? [])
                self?.logMessage("Sync state - \(fileList.status.state.rawValue)")
                self?.logMessage("Finished reading files. Total files \(fileList.files?.count ?? 0)")

                if let reauthAccounts = fileList.status.details?.filter({ $0.error != nil }) {
                    if let reauthAccounts = fileList.status.details?.filter({ $0.error != nil }) {
                        let allErrors = reauthAccounts.compactMap { $0.error }
                        allErrors.forEach { error in
                            self?.logErrorMessage("Error: '\(error.message ?? "n/a")', code: \(error.statusCode)")
                        }
                    }

                    if let retryAfter = reauthAccounts.compactMap({ $0.error?.retryAfter }).max() {
                        self?.retryAfter = retryAfter
                        self?.logWarningMessage("Data refresh blocked. \(retryAfter.timeIntervalRetryDescription()).")
                    }
                }

            case .failure(let error):
                self?.logErrorMessage("Error reading files: \(error)")
            }
        }
    }

    private func addAccountDetails(accounts: [SourceAccountData]) {
        DispatchQueue.main.async {
            accounts.forEach { [weak self] newAccount in
                if let index = self?.linkedAccounts.firstIndex(where: { $0.source.service.id == newAccount.serviceTypeId && $0.sourceAccount == nil }) {
                    self?.linkedAccounts[index].sourceAccount = newAccount
                }
            }
        }
    }

    private func updateReauthStatus(_ syncAccounts: [SyncAccount]) {
        DispatchQueue.main.async {
            syncAccounts.forEach { [weak self] syncAccount in
                let requiredReauth = (syncAccount.error?.statusCode ?? 0) == 511
                let retryAfter = syncAccount.error?.retryAfter

                if let index = self?.linkedAccounts.firstIndex(where: { ($0.sourceAccount?.id ?? "") == syncAccount.identifier }) {
                    self?.linkedAccounts[index].requiredReauth = requiredReauth
                    self?.linkedAccounts[index].retryAfter = retryAfter
                }
            }
        }
    }
    
    private func reset() {
        resetLogs()
        linkedAccounts = []
        userPreferences.reset()
    }

    // MARK: - Logs

    func logMessage(_ message: String, attachmentType: LogEntry.AttachmentType = LogEntry.AttachmentType.none, attachment: Data? = nil, metadataRaw: Data? = nil, metadataMapped: Data? = nil) {
        Task {
            let entry = LogEntry(message: message, attachmentType: attachmentType, attachment: attachment, attachmentRawMeta: metadataRaw, attachmentMappedMeta: metadataMapped)
            await self.loggingService.logMessage(entry)
        }
    }

    func logWarningMessage(_ message: String) {
        Task {
            let entry = LogEntry(message: message, state: .warning)
            await self.loggingService.logWarningMessage(entry)
        }
    }

    func logErrorMessage(_ message: String) {
        Task {
            let entry = LogEntry(message: message, state: .error)
            await self.loggingService.logErrorMessage(entry)
        }
    }

    func resetLogs() {
        Task {
            await self.loggingService.resetLogs()
        }
    }
}
