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

class ServicesViewModel: ObservableObject {
	
	@Published var sections: [ServiceSection] = []
	@Published var isLoading = false
	@Published var presentSourceSelector = false
	@Published var selectServiceCompletion: ((Service) -> Void)?
	@Published var currentContract: DigimeContract = Contracts.finSocMus {
		didSet {
			setContract(currentContract)
		}
	}
	@Published var services = [Service]() {
		didSet {
			preferences.setServices(newServices: services, for: currentContract.identifier)
		}
	}
	@Published var logs: [LogEntry] = [] {
		didSet {
			if let data = try? JSONEncoder().encode(logs) {
				FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "logs")
			}
		}
	}
	
	var isAuthorised: Bool {
		return preferences.credentials(for: currentContract.identifier) != nil
	}
	
	private var digiMe: DigiMe?
	private let preferences = UserPreferences.shared()

	init() {
		do {
			if
				let data = FilePersistentStorage(with: .documentDirectory).loadData(for: "logs"),
				let logHistory = try? data.decoded() as [LogEntry] {
				logs = logHistory
			}
			else {
				log(message: "This is where log messages appear")
			}
			
			services = preferences.services(for: currentContract.identifier)
			
			let config = try Configuration(appId: AppInfo.appId, contractId: currentContract.identifier, privateKey: currentContract.privateKey, authUsingExternalBrowser: true)
			digiMe = DigiMe(configuration: config)
		}
		catch {
			logError(message: "Unable to configure digi.me SDK: \(error)")
		}
	}
	
	func authorizeWithService() {
		guard !isLoading else {
			return
		}
		
		selectService { service in
			guard let service = service else {
				return
			}
			
			self.authorizeAndReadData(service: service)
		}
	}

	func addService() {
		guard !isLoading else {
			return
		}
		
		guard let credentials = preferences.credentials(for: currentContract.identifier) else {
			self.isLoading = false
			self.logWarning(message: "Current contract must be authorized first.")
			return
		}
		
		isLoading = true
		selectService { service in
			guard let service = service else {
				return
			}
			
			self.digiMe?.addService(identifier: service.identifier, credentials: credentials) { result in
				switch result {
				case .success(let newOrRefreshedCredentials):
					self.services.append(service)
					self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.currentContract.identifier)
					self.getData(credentials: newOrRefreshedCredentials, readOptions: service.options)
					
				case.failure(let error):
					self.isLoading = false
					self.logError(message: "Adding \(service.name) failed: \(error)")
				}
			}
		}
	}
	
	func refreshData() {
		guard !isLoading else {
			return
		}
		
		guard let credentials = preferences.credentials(for: currentContract.identifier) else {
			self.isLoading = false
			self.logWarning(message: "Current contract must be authorized first.")
			return
		}
		
		isLoading = true
		requestDataQuery(credentials: credentials) { [weak self] refreshedCredentials in
			self?.getServiceData(credentials: refreshedCredentials)
		}
	}

	func showContractDetails() {
		guard !isLoading else {
			return
		}
		
		isLoading = true
		digiMe?.contractDetails { result in
			self.isLoading = false
			switch result {
			case .success(let certificate):
				self.log(message: "Contract details:", attachmentType: LogEntry.AttachmentType.json, attachment: try? certificate.encoded())
			case .failure(let error):
				self.logError(message: "Unable to retrieve contract details: \(error)")
			}
		}
	}
	
	func deleteUser() {
		guard let credentials = preferences.credentials(for: currentContract.identifier) else {
			self.isLoading = false
			self.logWarning(message: "Contract must be authorized first.")
			return
		}
		
		isLoading = true
		digiMe?.deleteUser(credentials: credentials) { error in
			self.isLoading = false
			if let error = error {
				self.logError(message: error.description)
			}
			else {
				self.preferences.clearCredentials(for: self.currentContract.identifier)
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
					self.logs = []
					self.services = []
					self.preferences.reset()
					self.log(message: "Your user entry and the library deleted successfully")
				}
			}
		}
	}
	
	// MARK: - Logs
	
	func log(message: String, attachmentType: LogEntry.AttachmentType = LogEntry.AttachmentType.none, attachment: Data? = nil, metadataRaw: Data? = nil, metadataMapped: Data? = nil) {
		DispatchQueue.main.async {
			withAnimation {
				self.logs.append(LogEntry(message: message, attachmentType: attachmentType, attachment: attachment, attachmentRawMeta: metadataRaw, attachmentMappedMeta: metadataMapped))
			}
		}
	}
	
	func logWarning(message: String) {
		DispatchQueue.main.async {
			withAnimation {
				self.logs.append(LogEntry(state: .warning, message: message))
			}
		}
	}
	
	func logError(message: String) {
		DispatchQueue.main.async {
			withAnimation {
				self.logs.append(LogEntry(state: .error, message: message))
			}
		}
	}
	
	// MARK: - Private

	private func setContract(_ contract: DigimeContract) {
		services = preferences.services(for: contract.identifier)
		
		do {
			let config = try Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true)
			digiMe = DigiMe(configuration: config)
		}
		catch {
			logError(message: "Unable to configure digi.me SDK: \(error)")
		}
	}
	
	private func authorizeAndReadData(service: Service) {
		let credentials = preferences.credentials(for: currentContract.identifier)
		
		isLoading = true
		digiMe?.authorize(credentials: credentials, serviceId: service.identifier, readOptions: service.options) { result in
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.log(message: "Contract authorised successfully for service id: \(service.identifier)")
				self.services.append(service)
				self.preferences.setCredentials(newCredentials: newOrRefreshedCredentials, for: self.currentContract.identifier)
				self.getData(credentials: newOrRefreshedCredentials, readOptions: service.options)
				
			case.failure(let error):
				self.isLoading = false
				self.logError(message: "Authorization failed: \(error)")
			}
		}
	}
	
	private func selectService(completion: @escaping ((Service?) -> Void)) {
		isLoading = true
		digiMe?.availableServices(contractId: currentContract.identifier, filterAvailable: false) { result in
			self.isLoading = false
			switch result {
			case .success(let servicesInfo):
				self.selectServiceCompletion = completion
				self.fillSections(servicesInfo: servicesInfo)
				self.presentSourceSelector = true
				return
			case .failure(let error):
				self.logError(message: "Unable to retrieve services: \(error)")
			}
		}
	}
	
	private func fillSections(servicesInfo: ServicesInfo) {
		let services = servicesInfo.services
		
		let serviceGroupIds = Set(services.flatMap { $0.serviceGroupIds })
		let serviceGroups = servicesInfo.serviceGroups.filter { serviceGroupIds.contains($0.identifier) }
		
		var sections = [ServiceSection]()
		serviceGroups.forEach { group in
			let items = services
				.filter { $0.serviceGroupIds.contains(group.identifier) }
				.sorted { $0.name < $1.name }
			sections.append(ServiceSection(serviceGroupId: group.identifier, title: group.name, items: items))
		}
		
		sections.sort { $0.serviceGroupId < $1.serviceGroupId }
		self.sections = sections
	}
	
	private func getData(credentials: Credentials, readOptions: ReadOptions? = nil) {
		isLoading = true
		getAccounts(credentials: credentials) { updatedCredentials in
			self.getServiceData(credentials: updatedCredentials, readOptions: readOptions)
			self.isLoading = false
		}
	}
	
	private func getAccounts(credentials: Credentials, completion: @escaping (Credentials) -> Void) {
		isLoading = true
		digiMe?.readAccounts(credentials: credentials) { result in
			switch result {
			case .success(let accountsInfo):
				self.log(message: "Accounts info retrieved successfully")
				self.preferences.setAccounts(newAccounts: accountsInfo.accounts, for: self.currentContract.identifier)
				completion(credentials)
			case .failure(let error):
				if case .failure(.invalidSession) = result {
					// Need to create a new session
					self.requestDataQuery(credentials: credentials) { refreshedCredentials in
						self.getAccounts(credentials: refreshedCredentials, completion: completion)
					}
					return
				}
				
				self.logError(message: "Error retrieving accounts: \(error)")
			}
		}
	}
	
	private func requestDataQuery(credentials: Credentials, completion: @escaping (Credentials) -> Void) {
		digiMe?.requestDataQuery(credentials: credentials, readOptions: nil) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.currentContract.identifier)
				completion(refreshedCredentials)
				
			case.failure(let error):
				self.isLoading = false
				self.logError(message: "Authorization failed: \(error)")
			}
		}
	}

	private func getServiceData(credentials: Credentials, readOptions: ReadOptions? = nil) {
		isLoading = true
		digiMe?.readAllFiles(credentials: credentials, readOptions: nil, resultQueue: .global()) { result in
			switch result {
			case .success(let fileContainer):

				switch fileContainer.metadata {
				case .mapped(let metadata):
					self.log(message: "Downloaded mapped file \(fileContainer.identifier).", attachmentType: .jfs, attachment: fileContainer.data, metadataMapped: try? metadata.encoded())
				case .raw(let metadata):
					self.log(message: "Downloaded unmapped file \(fileContainer.identifier). File size: \(fileContainer.data.count) bytes.", attachmentType: LogEntry.mapped(mimeType: metadata.mimeType), attachment: fileContainer.data, metadataRaw: try? metadata.encoded())
				default:
					self.logError(message: "Error reading file 'Unexpected metadata'")
				}
								
				if !fileContainer.data.isEmpty {
					FilePersistentStorage(with: .documentDirectory).store(data: fileContainer.data, fileName: fileContainer.identifier)
				}
				
			case .failure(let error):
				self.logError(message: "Error reading file: \(error)")
			}
		} completion: { result in
			DispatchQueue.main.async {
				self.isLoading = false
			}
			switch result {
			case .success(let (fileList, refreshedCredentials)):
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: self.currentContract.identifier)
				self.log(message: "Finished reading files. Total files \(fileList.files?.count ?? 0)")

			case .failure(let error):
				self.logError(message: "Error reading files: \(error)")
			}
		}
	}
}
