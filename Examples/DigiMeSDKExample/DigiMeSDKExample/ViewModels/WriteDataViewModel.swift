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
	@Published var logs: [LogEntry] = [] {
		didSet {
			if let data = try? JSONEncoder().encode(logs) {
				FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "logs")
			}
		}
	}
	@Published var readCredentials: Credentials? {
		didSet {
			if let credentials = readCredentials {
				self.preferences.setCredentials(newCredentials: credentials, for: Contracts.readContract.identifier)
			}
			else {
				self.preferences.clearCredentials(for: Contracts.readContract.identifier)
			}
		}
	}
	@Published var writeCredentials: Credentials? {
		didSet {
			if let credentials = writeCredentials {
				self.preferences.setCredentials(newCredentials: credentials, for: Contracts.writeContract.identifier)
			}
			else {
				self.preferences.clearCredentials(for: Contracts.writeContract.identifier)
			}
		}
	}
	@Published var isLoading = false
	
	private var readDigiMe: DigiMe?
	private var writeDigiMe: DigiMe?
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
			
			writeCredentials = preferences.credentials(for: Contracts.writeContract.identifier)
			readCredentials = preferences.credentials(for: Contracts.readContract.identifier)

			let writeConfig = try Configuration(appId: AppInfo.appId, contractId: Contracts.writeContract.identifier, privateKey: Contracts.writeContract.privateKey)
			writeDigiMe = DigiMe(configuration: writeConfig)
			
			let readConfig = try Configuration(appId: AppInfo.appId, contractId: Contracts.readContract.identifier, privateKey: Contracts.readContract.privateKey)
			readDigiMe = DigiMe(configuration: readConfig)
		}
		catch {
			logError(message: "Unable to configure digi.me SDK: \(error)")
		}
	}
	
	func authorizeWriteContract() {
		isLoading = true
		writeDigiMe?.authorize(credentials: writeCredentials, linkToContractWithCredentials: readCredentials) { result in
			self.isLoading = false
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.log(message: "Write contract authorised successfully")
				self.writeCredentials = newOrRefreshedCredentials
				
			case.failure(let error):
				self.logError(message: "Authorization failed: \(error)")
			}
		}
	}
	
	func authorizeReadContract() {
		guard let credentials = writeCredentials else {
			self.isLoading = false
			logWarning(message: "Write contract needs to be authorized first")
			return
		}
		isLoading = true
		readDigiMe?.authorize(credentials: readCredentials, linkToContractWithCredentials: credentials) { result in
			self.isLoading = false
			switch result {
			case .success(let newOrRefreshedCredentials):
				self.log(message: "Read contract authorised successfully")
				self.readCredentials = newOrRefreshedCredentials
			case.failure(let error):
				self.logError(message: "Authorization failed: \(error)")
			}
		}
	}
	
	func showContractDetails() {
		isLoading = true
		readDigiMe?.contractDetails { result in
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
		isLoading = true
		guard let credentials = writeCredentials ?? readCredentials  else {
			self.isLoading = false
			self.logWarning(message: "At least one contract must be authorized firs.")
			return
		}
		
		writeDigiMe?.deleteUser(credentials: credentials) { error in
			self.isLoading = false
			if let error = error {
				self.logError(message: error.description)
			}
			else {
				self.writeCredentials = nil
				self.readCredentials = nil
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
					self.logs = []
					self.log(message: "Your user entry and the library deleted successfully")
				}
			}
		}
	}
	
	func uploadJson(data: Data, fileName: String) {
		guard let credentials = preferences.credentials(for: Contracts.writeContract.identifier) else {
			self.isLoading = false
			logWarning(message: "Write contract must be authorized first")
			return
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let metadata = RawFileMetadataBuilder(mimeType: .applicationJson, accounts: [String.random(length: 8)])
			.objectTypes([.init(name: "receipt")])
			.tags(["groceries"])
			.reference(["Receipt \(dateFormatter.string(from: Date()))"])
			.build()
		
		isLoading = true
		writeDigiMe?.write(data: data, metadata: metadata, credentials: credentials) { result in
			self.isLoading = false
			switch result {
			case .success(let refreshedCredentials):
				self.writeCredentials = refreshedCredentials
				self.log(message: "JSON file uploaded successfully", attachmentType: .json, attachment: data, metadataRaw: try? metadata.encoded())
			case .failure(let error):
				self.logError(message: "Upload JSON file error: \(error)")
			}
		}
	}
	
	func uploadPdf(data: Data, fileName: String) {
		guard let credentials = preferences.credentials(for: Contracts.writeContract.identifier) else {
			logWarning(message: "Write contract must be authorized first.")
			return
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let metadata = RawFileMetadataBuilder(mimeType: .applicationPdf, accounts: [String.random(length: 5)])
			.objectTypes([.init(name: "receipt")])
			.tags(["groceries"])
			.reference(["Receipt \(dateFormatter.string(from: Date()))"])
			.build()
	
		isLoading = true
		writeDigiMe?.write(data: data, metadata: metadata, credentials: credentials) { result in
			self.isLoading = false
			switch result {
			case .success(let refreshedCredentials):
				self.writeCredentials = refreshedCredentials
				self.log(message: "PDF file uploaded successfully", attachmentType: .pdf, attachment: data, metadataRaw: try? metadata.encoded())
				
			case .failure(let error):
				self.logError(message: "Upload PDF error: \(error)")
			}
		}
	}
	
	func uploadImage(data: Data, fileName: String) {
		guard let credentials = self.preferences.credentials(for: Contracts.writeContract.identifier) else {
			self.isLoading = false
			self.logWarning(message: "Write contract must be authorized first")
			return
		}
		
		let metadata = RawFileMetadataBuilder(mimeType: .imageJpeg, accounts: ["Account1"])
			.objectTypes([.init(name: "purchasedItem")])
			.tags(["groceries"])
			.reference([fileName])
			.build()
		
		isLoading = true
		writeDigiMe?.write(data: data, metadata: metadata, credentials: credentials) { result in
			self.isLoading = false
			switch result {
			case .success(let refreshedCredentials):
				self.writeCredentials = refreshedCredentials
				self.log(message: "Image file uploaded successfully", attachmentType: .image, attachment: data, metadataRaw: try? metadata.encoded())
			case .failure(let error):
				self.logError(message: "Upload image error: \(error)")
			}
		}
	}
	
	func readData() {
		guard let credentials = preferences.credentials(for: Contracts.readContract.identifier) else {
			self.isLoading = false
			self.logWarning(message: "Read contract must be authorized first.")
			return
		}
		
		isLoading = true
		readDigiMe?.requestDataQuery(credentials: credentials, readOptions: nil) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.readCredentials = refreshedCredentials
				self.readAllFiles(credentials: refreshedCredentials)
			case .failure(let error):
				self.isLoading = false
				self.logError(message: "Error requesting data query: \(error)")
			}
		}
	}
	
	// MARK: - Logs
	
	func log(message: String, attachmentType: LogEntry.AttachmentType = LogEntry.AttachmentType.none, attachment: Data? = nil, metadataRaw: Data? = nil, metadataMapped: Data? = nil) {
		withAnimation {
			logs.append(LogEntry(message: message, attachmentType: attachmentType, attachment: attachment, attachmentRawMeta: metadataRaw, attachmentMappedMeta: metadataMapped))
		}
	}
	
	func logWarning(message: String) {
		withAnimation {
			logs.append(LogEntry(state: .warning, message: message))
		}
	}
	
	func logError(message: String) {
		withAnimation {
			logs.append(LogEntry(state: .error, message: message))
		}
	}
	
	// MARK: - Private
	
	private func readAllFiles(credentials: Credentials) {
		readDigiMe?.readAllFiles(credentials: credentials, readOptions: nil) { result in
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
			self.isLoading = false
			switch result {
			case .success(let (fileList, refreshedCredentials)):
				self.readCredentials = refreshedCredentials
				self.log(message: "Finished reading files. Total files \(fileList.files?.count ?? 0)")

			case .failure(let error):
				self.logError(message: "Error reading files: \(error)")
			}
		}
	}
}
