//
//  WriteDataViewModel.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import PhotosUI
import SwiftUI

class WriteDataViewModel: ObservableObject {
	@Published var logEntries: [LogEntry] = [] {
		didSet {
            if let data = try? logEntries.encoded(dateEncodingStrategy: .millisecondsSince1970) {
				FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "logs_write")
			}
		}
	}
	@Published var credentialsForRead: Credentials? {
		didSet {
			if let credentials = credentialsForRead {
				self.userPreferences.setCredentials(newCredentials: credentials, for: Contracts.prodReadContract.identifier)
			}
			else {
				self.userPreferences.clearCredentials(for: Contracts.prodReadContract.identifier)
			}
		}
	}
	@Published var credentialsForWrite: Credentials? {
		didSet {
			if let credentials = credentialsForWrite {
				self.userPreferences.setCredentials(newCredentials: credentials, for: Contracts.prodWriteContract.identifier)
			}
			else {
				self.userPreferences.clearCredentials(for: Contracts.prodWriteContract.identifier)
			}
		}
	}
	@Published var loadingInProgress = false
	
	private var digiMeReadService: DigiMe?
	private var digiMeWriteService: DigiMe?
	private let userPreferences = UserPreferences.shared()
	
	init() {
		do {
			if
				let data = FilePersistentStorage(with: .documentDirectory).loadData(for: "logs_write"),
                let logHistory = try? data.decoded(dateDecodingStrategy: .millisecondsSince1970) as [LogEntry] {
				logEntries = logHistory
			}
			else {
				logMessage("This is where log messages appear")
			}
			
			credentialsForWrite = userPreferences.getCredentials(for: Contracts.prodWriteContract.identifier)
			credentialsForRead = userPreferences.getCredentials(for: Contracts.prodReadContract.identifier)

			let writeConfig = try Configuration(appId: Contracts.prodWriteContract.appId, contractId: Contracts.prodWriteContract.identifier, privateKey: Contracts.prodWriteContract.privateKey)
			digiMeWriteService = DigiMe(configuration: writeConfig)
			
			let readConfig = try Configuration(appId: Contracts.prodReadContract.appId, contractId: Contracts.prodReadContract.identifier, privateKey: Contracts.prodReadContract.privateKey)
			digiMeReadService = DigiMe(configuration: readConfig)
		}
		catch {
			logErrorMessage("Unable to configure digi.me SDK: \(error)")
		}
	}
	
	func authorizeWriteContract() {
		loadingInProgress = true
		digiMeWriteService?.authorize(credentials: credentialsForWrite, linkToContractWithCredentials: credentialsForRead) { result in
			self.loadingInProgress = false
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.logMessage("Write contract authorised successfully")
				self.credentialsForWrite = newOrRefreshedCredentials
				
			case.failure(let error):
				self.logErrorMessage("Authorization failed: \(error)")
			}
		}
	}
	
	func authorizeReadContract() {
		guard let credentials = credentialsForWrite else {
			self.loadingInProgress = false
			logWarningMessage("Write contract needs to be authorized first")
			return
		}
        
		loadingInProgress = true
		digiMeReadService?.authorize(credentials: credentialsForRead, linkToContractWithCredentials: credentials) { result in
			self.loadingInProgress = false
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.logMessage("Read contract authorised successfully")
				self.credentialsForRead = newOrRefreshedCredentials
			case.failure(let error):
				self.logErrorMessage("Authorization failed: \(error)")
			}
		}
	}
	
	func displayContractDetails() {
		loadingInProgress = true
		digiMeReadService?.contractDetails { result in
			self.loadingInProgress = false
			switch result {
			case .success(let certificate):
				self.logMessage("Contract details:", attachmentType: LogEntry.AttachmentType.json, attachment: try? certificate.encoded())
			case .failure(let error):
				self.logErrorMessage("Unable to retrieve contract details: \(error)")
			}
		}
	}
	
	func removeUser() {
		loadingInProgress = true
		guard let credentials = credentialsForWrite ?? credentialsForRead else {
			self.loadingInProgress = false
			self.logWarningMessage("At least one contract must be authorized firs.")
			return
		}
		
		digiMeWriteService?.deleteUser(credentials: credentials) { error in
			self.loadingInProgress = false
			if let error = error {
				self.logErrorMessage(error.description)
			}
			else {
				self.credentialsForWrite = nil
				self.credentialsForRead = nil
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
					self.logEntries = []
					self.logMessage("Your user entry and the library deleted successfully")
				}
			}
		}
	}
	
	func submitJsonData(data: Data, fileName: String) {
		guard let credentials = userPreferences.getCredentials(for: Contracts.prodWriteContract.identifier) else {
			self.loadingInProgress = false
			logWarningMessage("Write contract must be authorized first")
			return
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let metadata = RawFileMetadataBuilder(mimeType: .applicationJson, accounts: [String.random(length: 8)])
			.objectTypes([.init(name: "receipt")])
			.tags(["groceries"])
			.reference(["Receipt \(dateFormatter.string(from: Date()))"])
			.build()
		
		loadingInProgress = true
		digiMeWriteService?.pushDataToLibrary(data: data, metadata: metadata, credentials: credentials) { result in
			self.loadingInProgress = false
			switch result {
			case .success(let refreshedCredentials):
				self.credentialsForWrite = refreshedCredentials
				self.logMessage("JSON file uploaded successfully", attachmentType: .json, attachment: data, metadataRaw: try? metadata.encoded())
			case .failure(let error):
				self.logErrorMessage("Upload JSON file error: \(error)")
			}
		}
	}
	
	func submitPdfData(data: Data, fileName: String) {
		guard let credentials = userPreferences.getCredentials(for: Contracts.prodWriteContract.identifier) else {
			logWarningMessage("Write contract must be authorized first.")
			return
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let metadata = RawFileMetadataBuilder(mimeType: .applicationPdf, accounts: [String.random(length: 5)])
			.objectTypes([.init(name: "receipt")])
			.tags(["groceries"])
			.reference(["Receipt \(dateFormatter.string(from: Date()))"])
			.build()
	
		loadingInProgress = true
		digiMeWriteService?.pushDataToLibrary(data: data, metadata: metadata, credentials: credentials) { result in
			self.loadingInProgress = false
			switch result {
			case .success(let refreshedCredentials):
				self.credentialsForWrite = refreshedCredentials
				self.logMessage("PDF file uploaded successfully", attachmentType: .pdf, attachment: data, metadataRaw: try? metadata.encoded())
				
			case .failure(let error):
				self.logErrorMessage("Upload PDF error: \(error)")
			}
		}
	}
	
	func submitImageData(data: Data, fileName: String) {
		guard let credentials = self.userPreferences.getCredentials(for: Contracts.prodWriteContract.identifier) else {
			self.loadingInProgress = false
			self.logWarningMessage("Write contract must be authorized first")
			return
		}
		
		let metadata = RawFileMetadataBuilder(mimeType: .imageJpeg, accounts: ["Account1"])
			.objectTypes([.init(name: "purchasedItem")])
			.tags(["groceries"])
			.reference([fileName])
			.build()
		
		loadingInProgress = true
		digiMeWriteService?.pushDataToLibrary(data: data, metadata: metadata, credentials: credentials) { result in
			self.loadingInProgress = false
			switch result {
			case .success(let refreshedCredentials):
				self.credentialsForWrite = refreshedCredentials
				self.logMessage("Image file uploaded successfully", attachmentType: .image, attachment: data, metadataRaw: try? metadata.encoded())
			case .failure(let error):
				self.logErrorMessage("Upload image error: \(error)")
			}
		}
	}
	
	func retrieveData() {
		guard let credentials = userPreferences.getCredentials(for: Contracts.prodReadContract.identifier) else {
			self.loadingInProgress = false
			self.logWarningMessage("Read contract must be authorized first.")
			return
		}
		
		loadingInProgress = true
		digiMeReadService?.requestDataQuery(credentials: credentials, readOptions: nil) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.credentialsForRead = refreshedCredentials
				self.fetchAllFiles(credentials: refreshedCredentials)
			case .failure(let error):
				self.loadingInProgress = false
				self.logErrorMessage("Error requesting data query: \(error)")
			}
		}
	}
	
	// MARK: - Logs
	
	func logMessage(_ message: String, attachmentType: LogEntry.AttachmentType = LogEntry.AttachmentType.none, attachment: Data? = nil, metadataRaw: Data? = nil, metadataMapped: Data? = nil) {
		withAnimation {
			logEntries.append(LogEntry(message: message, attachmentType: attachmentType, attachment: attachment, attachmentRawMeta: metadataRaw, attachmentMappedMeta: metadataMapped))
		}
	}
	
	func logWarningMessage(_ message: String) {
		withAnimation {
			logEntries.append(LogEntry(state: .warning, message: message))
		}
	}
	
	func logErrorMessage(_ message: String) {
		withAnimation {
			logEntries.append(LogEntry(state: .error, message: message))
		}
	}
	
	// MARK: - Private
	
	private func fetchAllFiles(credentials: Credentials) {
		digiMeReadService?.readAllFiles(credentials: credentials, readOptions: nil) { result in
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
		} completion: { result in
			self.loadingInProgress = false
			switch result {
			case .success(let (fileList, refreshedCredentials)):
				self.credentialsForRead = refreshedCredentials
				self.logMessage("Finished reading files. Total files \(fileList.files?.count ?? 0)")

			case .failure(let error):
				self.logErrorMessage("Error reading files: \(error)")
			}
		}
	}
}
