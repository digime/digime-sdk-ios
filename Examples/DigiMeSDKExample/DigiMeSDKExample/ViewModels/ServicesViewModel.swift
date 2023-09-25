//
//  ServicesViewModel.swift
//  DigiMeSDKExample
//
//  Created on 21/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import SwiftUI

@MainActor
class ServicesViewModel: ObservableObject {
    @AppStorage("ActiveServiceContractId") private var activeContractId: String = Contracts.development.identifier

    @Published var activeContract: DigimeContract = Contracts.development {
        didSet {
            updateContract(activeContract)
        }
    }
    @Published var serviceSections: [ServiceSection] = []
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
    @Published var serviceSelectionCompletionHandler: ((Service) -> Void)?

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
    
    init() {
        do {
            if
                let logData = FilePersistentStorage(with: .documentDirectory).loadData(for: "logs_services"),
                let savedLogEntries = try? logData.decoded(dateDecodingStrategy: .millisecondsSince1970) as [LogEntry] {
                logEntries = savedLogEntries
            }
            else {
                logMessage("This is where log messages appear")
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
        
        chooseService { selectedService in
            guard let selectedService = selectedService else {
                return
            }
            
            self.authenticateAndFetchData(service: selectedService)
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
        chooseService { selectedService in
            guard let selectedService = selectedService else {
                return
            }
            
            self.shouldDisplayCancelButton = true
            self.digiMeService?.addService(identifier: selectedService.identifier, credentials: accountCredentials) { refreshedCredentials, addServiceResult in
                self.userPreferences.setCredentials(newCredentials: refreshedCredentials, for: self.activeContract.identifier)
                self.shouldDisplayCancelButton = false
                switch addServiceResult {
                case .success:
                    self.linkedAccounts.append(LinkedAccount(service: selectedService))
                    self.fetchData(credentials: refreshedCredentials, readOptions: selectedService.options)
                    
                case.failure(let error):
                    self.isLoadingData = false
                    self.logErrorMessage("Adding \(selectedService.name) failed: \(error)")
                }
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
            self.isLoadingData = false
            self.logWarningMessage("Contract must be authorized first.")
            return
        }
        
        isLoadingData = true
        digiMeService?.deleteUser(credentials: accountCredentials) { refreshedCredentials, result in
            self.isLoadingData = false
            
            switch result {
            case .success:
                self.userPreferences.clearCredentials(for: self.activeContract.identifier)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.logEntries = []
                    self.linkedAccounts = []
                    self.userPreferences.reset()
                    self.logMessage("Your user entry and the library deleted successfully")
                }
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

    private func authenticateAndFetchData(service: Service) {
        DispatchQueue.main.async {
            self.isLoadingData = true
            self.shouldDisplayCancelButton = true
        }
        
        let accountCredentials = userPreferences.getCredentials(for: activeContract.identifier)
        digiMeService?.authorize(credentials: accountCredentials, serviceId: service.identifier, readOptions: service.options) { result in
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

    private func chooseService(completion: @escaping ((Service?) -> Void)) {
        isLoadingData = true
        digiMeService?.availableServices(contractId: activeContract.identifier, filterAvailable: false) { result in
            self.isLoadingData = false
            switch result {
            case .success(let serviceInfo):
                self.serviceSelectionCompletionHandler = completion
                self.populateSections(serviceInfo: serviceInfo)
                self.shouldDisplaySourceSelector = true
                return
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
        serviceGroups.forEach { group in
            let items = services
                .filter { $0.serviceGroupIds.contains(group.identifier) }
                .sorted { $0.name < $1.name }
            sections.append(ServiceSection(serviceGroupId: group.identifier, title: group.name, items: items))
        }
        
        sections.sort { $0.serviceGroupId < $1.serviceGroupId }
        self.serviceSections = sections
        userPreferences.servicesInfo = serviceInfo
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
}
