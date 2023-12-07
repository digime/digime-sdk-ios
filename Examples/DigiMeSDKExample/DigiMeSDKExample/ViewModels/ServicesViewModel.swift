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
import SwiftUI

enum ConnectSourceViewState {
    case none, sources, sampleData
}

@MainActor
class ServicesViewModel: ObservableObject {
    @Published var activeContract: DigimeContract = Contracts.development {
        didSet {
            updateContract(activeContract)
        }
    }
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
    @Published var logEntries: [LogEntry] = [] {
        didSet {
            if let data = try? logEntries.encoded(dateEncodingStrategy: .millisecondsSince1970) {
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "logs_services")
            }
        }
    }
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
    @Published var serviceSelectionCompletionHandler: ((Service, String?) -> Void)?
    
    var onShowSampleDataSelectorChanged: ((Bool) -> Void)?
    var onShowSampleDataErrorChanged: ((Bool) -> Void)?
    var onProceedSampleDatasetChanged: ((Bool) -> Void)?
    
    var isAuthorized: Bool {
        return userPreferences.getCredentials(for: activeContract.identifier) != nil
    }

    var contracts = [
        Contracts.prodFinSocMus,
        Contracts.prodFitHealth,
        Contracts.development,
        Contracts.integration,
        Contracts.staging,
        Contracts.test05,
        Contracts.test08,
    ]

    private let userPreferences = UserPreferences.shared()
    
    private var digiMeService: DigiMe?

    private var activeContractId: String {
        get {
            UserDefaults.standard.string(forKey: "ActiveServiceContractId") ?? Contracts.development.identifier
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ActiveServiceContractId")
        }
    }

    init(sections: [ServiceSection]? = nil) {
        do {
            if
                let logData = FilePersistentStorage(with: .documentDirectory).loadData(for: "logs_services"),
                let savedLogEntries = try? logData.decoded(dateDecodingStrategy: .millisecondsSince1970) as [LogEntry] {
                logEntries = savedLogEntries
            }
            else {
                logMessage("This is where log messages appear")
            }
            
            // support SwiftUI preview
            if let sections = sections {
                self.serviceSections = sections
                self.sampleDataSections = sections
            }
            
            linkedAccounts = userPreferences.getLinkedAccounts(for: activeContract.identifier)
            
            let sdkConfig = try Configuration(appId: activeContract.appId, contractId: activeContract.identifier, privateKey: activeContract.privateKey, authUsingExternalBrowser: true, baseUrl: activeContract.baseURL)
            digiMeService = DigiMe(configuration: sdkConfig)
        }
        catch {
            logErrorMessage("Unable to configure digi.me SDK: \(error)")
        }
    }

    func authorizeSelectedService() {
        guard !isLoadingData else {
            return
        }
        
        chooseService { selectedService, sampleDataSetId in
            guard let selectedService = selectedService else {
                return
            }
            
            if let sampleDataSetId = sampleDataSetId {
                self.authenticateAndFetchData(service: selectedService, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: true)
            }
            else {
                self.authenticateAndFetchData(service: selectedService)
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
        digiMeService?.reauthorizeAccount(accountId: accountId, credentials: accountCredentials) { refreshedCredentials, reauthResult in
            self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)
            self.shouldDisplayCancelButton = false
            switch reauthResult {
            case .success:
                self.fetchData(credentials: refreshedCredentials)
                if let index = self.linkedAccounts.firstIndex(where: { $0 == connectedAccount }) {
                    self.linkedAccounts[index].requiredReauth = false
                }
            case .failure(let error):
                self.isLoadingData = false
                self.logErrorMessage("Reauthorizing \(connectedAccount.service.name) failed: \(error)")
            }
        }
    }

    func addNewService() {
        guard !isLoadingData else {
            return
        }
        
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            isLoadingData = false
            logWarningMessage("Current contract must be authorized first.")
            return
        }
        
        isLoadingData = true
        chooseService { selectedService, sampleDataSetId in
            guard let selectedService = selectedService else {
                return
            }
                        
            if let sampleDataSetId = sampleDataSetId {
                self.addAccountAndFetchData(service: selectedService, credentials: accountCredentials, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: true)
            }
            else {
                self.addAccountAndFetchData(service: selectedService, credentials: accountCredentials)
            }
        }
    }
    
    func reloadServiceData(readOptions: ReadOptions? = nil) {
        guard !isLoadingData else {
            return
        }
        
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            isLoadingData = false
            logWarningMessage("Current contract must be authorized first.")
            return
        }
        
        isLoadingData = true
        requestDataFetch(credentials: accountCredentials, readOptions: readOptions) { [weak self] refreshedCredentials in
            self?.fetchServiceData(credentials: refreshedCredentials, readOptions: readOptions)
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
    
    func fetchDemoDataSetsInfoForService(service: Service) {
        guard !isLoadingData else {
            return
        }

        isLoadingData = true
        digiMeService?.fetchDemoDataSetsInfoForService(serviceId: "\(service.identifier)") { result in
            self.isLoadingData = false
            switch result {
            case .success(let datasets):
                self.sampleDatasets = datasets
                if datasets.keys.count > 1 {
                    self.handleSampleDataSelectorChange()
                }
                else if datasets.keys.count == 1 {
//                    if self.isAuthorized {
//                        self.addNewService()
//                    }
//                    else {
//                        self.authenticateAndFetchData(service: service, sampleDataSetId: datasets.first?.key, sampleDataAutoOnboard: true)
//                    }
                    self.handleProceedSampleDatasetChange()
                }
                else {
                    self.handleSampleDataErrorChange()
                }
            case .failure(let error):
                self.logErrorMessage("Unable to retrieve sample datasets details: \(error)")
                self.handleSampleDataErrorChange()
            }
        }
    }
    
    func handleSampleDataSelectorChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onShowSampleDataSelectorChanged?(true)
        }
    }
    
    func handleSampleDataErrorChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onShowSampleDataErrorChanged?(true)
        }
    }
    
    func handleProceedSampleDatasetChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onProceedSampleDatasetChanged?(true)
        }
    }
    
    func displayContractDetails() {
        guard !isLoadingData else {
            return
        }
        
        isLoadingData = true
        digiMeService?.contractDetails { result in
            self.isLoadingData = false
            switch result {
            case .success(let certificate):
                self.logMessage("Contract details:", attachmentType: LogEntry.AttachmentType.json, attachment: try? certificate.encoded())
            case .failure(let error):
                self.logErrorMessage("Unable to retrieve contract details: \(error)")
            }
        }
    }

    func removeUser() {
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            self.logWarningMessage("Contract must be authorized first.")
            return
        }

        guard accountCredentials.token.refreshToken.isValid else {
            self.reset()
            return
        }
        
        isLoadingData = true
        digiMeService?.deleteUser(credentials: accountCredentials) { refreshedCredentials, result in
            self.isLoadingData = false
            
            switch result {
            case .success:
                self.userPreferences.clearCredentials(for: self.activeContract.identifier)
                self.logEntries = []
                self.linkedAccounts = []
                self.logMessage("Your user entry and the library deleted successfully")
            case .failure(let error):
                self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)
                self.logErrorMessage(error.description)
            }
        }
    }

    func fetchReport(for serviceTypeName: String, format: String, from: TimeInterval, to: TimeInterval) {
        guard let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier) else {
            self.isLoadingData = false
            self.logWarningMessage("Contract must be authorized first.")
            return
        }

        isLoadingData = true
        digiMeService?.exportPortabilityReport(for: serviceTypeName, format: format, from: from, to: to, credentials: accountCredentials) { refreshedCredentials, result in
            self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)
            self.isLoadingData = false
            switch result {
            case .success(let data):
                let fileName = "Report_\(serviceTypeName)_\(Date().description).\(format)"
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: fileName) { url in
                    guard let url = url else {
                        self.logErrorMessage("An error occured storing '\(fileName)' file")
                        return
                    }
                    self.xmlReportURL = url
                    self.logMessage("Report successfully shared.")
                    self.shouldDisplayShareSheet = true
                }

            case .failure(let error):
                self.logErrorMessage("Error requesting data export: \(error)")
            }
        }
    }

    func stopFetchingData() {
        isLoadingData = false
        shouldDisplayCancelButton = false
        logWarningMessage("Data retrieval was cancelled by the user.")
    }
	
    // MARK: - Logs

    func logMessage(_ message: String, attachmentType: LogEntry.AttachmentType = LogEntry.AttachmentType.none, attachment: Data? = nil, metadataRaw: Data? = nil, metadataMapped: Data? = nil) {
        DispatchQueue.main.async {
            withAnimation {
                let entry = LogEntry(message: message, attachmentType: attachmentType, attachment: attachment, attachmentRawMeta: metadataRaw, attachmentMappedMeta: metadataMapped)
                self.logEntries.append(entry)
            }
        }
    }

    func logWarningMessage(_ message: String) {
        DispatchQueue.main.async {
            withAnimation {
                self.logEntries.append(LogEntry(state: .warning, message: message))
            }
        }
    }

    func logErrorMessage(_ message: String) {
        DispatchQueue.main.async {
            withAnimation {
                self.logEntries.append(LogEntry(state: .error, message: message))
            }
        }
    }

    // MARK: - Private

    private func updateContract(_ contract: DigimeContract) {
        linkedAccounts = userPreferences.getLinkedAccounts(for: contract.identifier)
        activeContractId = contract.identifier
        do {
            let config = try Configuration(appId: contract.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true, baseUrl: contract.baseURL)
            digiMeService = DigiMe(configuration: config)
        }
        catch {
            logErrorMessage("Unable to configure digi.me SDK: \(error)")
        }
    }

    private func authenticateAndFetchData(service: Service, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil) {
        DispatchQueue.main.async {
            self.isLoadingData = true
            self.shouldDisplayCancelButton = true
        }
        
        let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier)
        digiMeService?.authorize(credentials: accountCredentials, serviceId: service.identifier, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataAutoOnboard, readOptions: service.options) { result in
            self.shouldDisplayCancelButton = false
            
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.logMessage("Contract authorised successfully for service id: \(service.identifier)")
                self.linkedAccounts.append(LinkedAccount(service: service))
                self.userPreferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.activeContract.identifier)
                self.fetchData(credentials: newOrRefreshedCredentials, readOptions: service.options)
                
            case.failure(let error):
                self.isLoadingData = false
                self.logErrorMessage("Authorization failed: \(error)")
            }
        }
    }

    private func addAccountAndFetchData(service: Service, credentials: Credentials, sampleDataSetId: String? = nil, sampleDataAutoOnboard: Bool? = nil) {
        self.shouldDisplayCancelButton = true
        self.digiMeService?.addService(identifier: service.identifier, sampleDataSetId: sampleDataSetId, sampleDataAutoOnboard: sampleDataSetId != nil, credentials: credentials) { refreshedCredentials, addServiceResult in
            self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)
            self.shouldDisplayCancelButton = false
            switch addServiceResult {
            case .success:
                self.linkedAccounts.append(LinkedAccount(service: service))
                self.fetchData(credentials: refreshedCredentials, readOptions: service.options)
                
            case.failure(let error):
                self.isLoadingData = false
                self.logErrorMessage("Adding \(service.name) failed: \(error)")
            }
        }
    }
    
    private func chooseService(completion: @escaping ((Service?, String?) -> Void)) {
        serviceSelectionCompletionHandler = completion
        var showServiceSelector = true
        
        if
            let services = userPreferences.readServiceSections(for: activeContractId),
            let sampleData = userPreferences.readServiceSampleDataSections(for: activeContractId) {

            self.serviceSections = services
            self.sampleDataSections = sampleData
            showServiceSelector = false
            isLoadingData = false
            withAnimation {
                shouldDisplaySourceSelector = true
            }
        }
        else {
            isLoadingData = true
        }
        
        digiMeService?.availableServices(contractId: activeContract.identifier, filterAvailable: false) { result in
            self.isLoadingData = false
            switch result {
            case .success(let serviceInfo):
//                FilePersistentStorage(with: .documentDirectory).store(object: serviceInfo, fileName: "discovery.json")
                self.populateSections(serviceInfo: serviceInfo)
                if showServiceSelector {
                    withAnimation {
                        self.shouldDisplaySourceSelector = true
                    }
                }
            case .failure(let error):
                self.logErrorMessage("Unable to retrieve services: \(error)")
            }
        }
    }

    private func populateSections(serviceInfo: ServicesInfo) {
        let services = serviceInfo.services
        
        let serviceGroupIds = Set(services.flatMap { $0.serviceGroupIds })
        let serviceGroups = serviceInfo.serviceGroups.filter { serviceGroupIds.contains($0.identifier) }
        
        var sections = [ServiceSection]()
        var sampleDataSections = [ServiceSection]()
        
        serviceGroups.forEach { group in
            let items = services
                .filter { $0.serviceGroupIds.contains(group.identifier) }
                .sorted { $0.name < $1.name }
            sections.append(ServiceSection(serviceGroupId: group.identifier, title: group.name, items: items.filter { !$0.sampleDataOnly }))
            sampleDataSections.append(ServiceSection(serviceGroupId: group.identifier, title: group.name, items: items))
        }
        
        sections.sort { $0.serviceGroupId < $1.serviceGroupId }
        sampleDataSections.sort { $0.serviceGroupId < $1.serviceGroupId }
        self.serviceSections = sections
        self.userPreferences.setServiceSections(sections: sections, for: activeContractId)
        self.sampleDataSections = sampleDataSections
        self.userPreferences.setServiceSampleDataSections(sections: sampleDataSections, for: activeContractId)
    }

    private func fetchData(credentials: Credentials, readOptions: ReadOptions? = nil) {
        isLoadingData = true
        fetchAccounts(credentials: credentials) { updatedCredentials in
            self.fetchServiceData(credentials: updatedCredentials, readOptions: readOptions)
            self.isLoadingData = false
        }
    }

    private func fetchAccounts(credentials: Credentials, completion: @escaping (Credentials) -> Void) {
        DispatchQueue.main.async {
            self.isLoadingData = true
        }
        
        digiMeService?.readAccounts(credentials: credentials) { refreshedCredentials, result in
            switch result {
            case .success(let accountDetails):
                self.logMessage("Accounts info retrieved successfully")
                self.addAccountDetails(accounts: accountDetails)
                completion(refreshedCredentials)
            case .failure(let error):
                if case .failure(.invalidSession) = result {
                    // Need to create a new session
                    self.requestDataFetch(credentials: refreshedCredentials) { renewedCredentials in
                        self.fetchAccounts(credentials: renewedCredentials, completion: completion)
                    }
                    return
                }
                
                self.logErrorMessage("Error retrieving accounts: \(error)")
            }
        }
    }

    private func requestDataFetch(credentials: Credentials, readOptions: ReadOptions? = nil, completion: @escaping (Credentials) -> Void) {
        digiMeService?.requestDataQuery(credentials: credentials, readOptions: readOptions) { refreshedCredentials, result in
            self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)

            switch result {
            case .success:
                completion(refreshedCredentials)
                
            case.failure(let error):
                self.isLoadingData = false
                self.logErrorMessage("Authorization failed: \(error)")
            }
        }
    }

    private func fetchServiceData(credentials: Credentials, readOptions: ReadOptions? = nil) {
        DispatchQueue.main.async {
            self.isLoadingData = true
        }
        
        digiMeService?.readAllFiles(credentials: credentials, readOptions: readOptions, resultQueue: .global()) { result in
            switch result {
            case .success(let fileContainer):

                switch fileContainer.metadata {
                case .mapped(let metadata):
                    self.logMessage("Downloaded mapped file \(fileContainer.identifier).", attachmentType: .jfs, attachment: fileContainer.data, metadataMapped: try? metadata.encoded())
                case .raw(let metadata):
                    self.logMessage("Downloaded unmapped file \(fileContainer.identifier). File size: \(fileContainer.data.count) bytes.", attachmentType: LogEntry.mapped(mimeType: metadata.mimeType), attachment: fileContainer.data, metadataRaw: try? metadata.encoded())
                default:
                    self.logErrorMessage("Error reading file 'Unexpected metadata'")
                }
                                
                if !fileContainer.data.isEmpty {
                    FilePersistentStorage(with: .documentDirectory).store(data: fileContainer.data, fileName: fileContainer.identifier)
                }
                
            case .failure(let error):
                self.logErrorMessage("Error reading file: \(error)")
            }
        } completion: { refreshedCredentials, result in
            self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)

            DispatchQueue.main.async {
                self.isLoadingData = false
            }
            switch result {
            case .success(let fileList):
                if
                    let reauthAccounts = fileList.status.details?.filter({ $0.error != nil }),
                    !reauthAccounts.isEmpty {
                    
                    self.updateReauthenticationStatus(reauthAccounts: reauthAccounts)
                }
                self.logMessage("Sync state - \(fileList.status.state.rawValue)")
                self.logMessage("Finished reading files. Total files \(fileList.files?.count ?? 0)")

            case .failure(let error):
                self.logErrorMessage("Error reading files: \(error)")
            }
        }
    }

    private func addAccountDetails(accounts: [SourceAccountData]) {
        DispatchQueue.main.async {
            accounts.forEach { newAccount in
                if let index = self.linkedAccounts.firstIndex(where: { $0.service.name == newAccount.serviceTypeName && $0.sourceAccount == nil }) {
                    self.linkedAccounts[index].sourceAccount = newAccount
                }
            }
        }
    }

    private func updateReauthenticationStatus(reauthAccounts: [SyncAccount]) {
        DispatchQueue.main.async {
            reauthAccounts.forEach { reauth in
                if let index = self.linkedAccounts.firstIndex(where: { ($0.sourceAccount?.id ?? "") == reauth.identifier && !$0.requiredReauth }) {
                    self.linkedAccounts[index].requiredReauth = true
                }
            }
        }
    }
    
    private func reset() {
        self.logEntries = []
        self.linkedAccounts = []
        self.userPreferences.reset()
    }
}
