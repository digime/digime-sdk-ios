//
//  WriteDataViewController.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit

class WriteDataViewController: UIViewController {
    
    @IBOutlet private var authorizeWriteButton: UIButton!
    @IBOutlet private var uploadPDFButton: UIButton!
    @IBOutlet private var uploadImageButton: UIButton!
	@IBOutlet private var uploadJSONButton: UIButton!
	
    @IBOutlet private var authorizeReadButton: UIButton!
    @IBOutlet private var contractDetailsReadButton: UIButton!
    @IBOutlet private var contractDetailsWriteButton: UIButton!
    @IBOutlet private var readDataButton: UIButton!
    
    @IBOutlet private var deleteUserButton: UIButton!
    @IBOutlet private var loggerTextView: UITextView!
    
    private var logger: Logger!
    
    private var writeDigiMe: DigiMe!
    private var readDigiMe: DigiMe!
    private let credentialCache = CredentialCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Write Data Example"
        
        logger = Logger(textView: loggerTextView)
        logger.log(message: "This is where log messages appear.")
        
        do {
            let writeConfig = try Configuration(appId: AppInfo.appId, contractId: Contracts.writeContract.identifier, privateKey: Contracts.writeContract.privateKey)
            writeDigiMe = DigiMe(configuration: writeConfig)
            
            let readConfig = try Configuration(appId: AppInfo.appId, contractId: Contracts.readContract.identifier, privateKey: Contracts.readContract.privateKey)
            readDigiMe = DigiMe(configuration: readConfig)
            
            updateUI()
        }
        catch {
            logger.log(message: "Unable to configure digi.me SDK: \(error)")
        }
    }
    
    @IBAction private func authorizeWriteContract() {
        let writeCredentials = credentialCache.credentials(for: Contracts.writeContract.identifier)
        let readCredentials = credentialCache.credentials(for: Contracts.readContract.identifier)
        writeDigiMe.authorize(credentials: writeCredentials, linkToContractWithCredentials: readCredentials) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.credentialCache.setCredentials(newOrRefreshedCredentials, for: Contracts.writeContract.identifier)
                self.updateUI()
                
            case.failure(let error):
                self.logger.log(message: "Authorization failed: \(error)")
            }
        }
    }
    
    @IBAction private func authorizeReadContract() {
        guard let writeCredentials = credentialCache.credentials(for: Contracts.writeContract.identifier) else {
            logger.log(message: "Write contract needs to be authorized first")
            return
        }
        
        let readCredentials = credentialCache.credentials(for: Contracts.readContract.identifier)
        readDigiMe.authorize(credentials: readCredentials, linkToContractWithCredentials: writeCredentials) { result in
            switch result {
            case .success(let newOrRefreshedCredentials):
                self.credentialCache.setCredentials(newOrRefreshedCredentials, for: Contracts.readContract.identifier)
                self.updateUI()
                
            case.failure(let error):
                self.logger.log(message: "Authorization failed: \(error)")
            }
        }
    }
    
    @IBAction private func uploadJson() {
        guard let credentials = credentialCache.credentials(for: Contracts.writeContract.identifier) else {
            self.logger.log(message: "Write contract must be authorized first.")
            return
        }
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let metadata = RawFileMetadataBuilder(mimeType: .applicationJson, accounts: [String.random(length: 8)])
                .objectTypes([.init(name: "receipt")])
                .tags(["groceries"])
                .reference(["Receipt \(dateFormatter.string(from: Date()))"])
                .build()
            
            let jsonData = try JSONEncoder().encode(Receipt())
            
            writeDigiMe.writeDirect(data: jsonData, metadata: metadata, credentials: credentials) { result in
                switch result {
                case .success(let refreshedCredentials):
                    self.credentialCache.setCredentials(refreshedCredentials, for: Contracts.writeContract.identifier)
                    let jsonString: String
                    if
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                        let prettyJsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                        let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                        jsonString = prettyJsonString
                    }
                    else {
                        jsonString = "Unable to display JSON"
                    }
                    self.logger.log(message: "Uploaded JSON:\n\(jsonString)")
                    
                case .failure(let error):
                    self.logger.log(message: "Upload JSON file error: \(error)")
                }
            }
        }
        catch {
            logger.log(message: "JSON files parsing Error: \(error)")
        }
    }
	
	@IBAction private func uploadPdf() {
		guard let credentials = preferences.credentials(for: Contracts.writeContract.identifier) else {
			self.logger.log(message: "Write contract must be authorized first.")
			return
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let metadata = RawFileMetadataBuilder(mimeType: .applicationPdf, accounts: [String.random(length: 5)])
			.objectTypes([.init(name: "receipt")])
			.tags(["groceries"])
			.reference(["Receipt \(dateFormatter.string(from: Date()))"])
			.build()
		
		guard
			let url = Bundle.main.url(forResource: "uploadExample", withExtension: "pdf"),
			let pdfData = try? Data(contentsOf: url) else {
			
			self.logger.log(message: "Error reading PDF resource file.")
			return
		}
				
		writeDigiMe.writeDirect(data: pdfData, metadata: metadata, credentials: credentials) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: Contracts.writeContract.identifier)
				self.logger.log(message: "Uploaded PDF file.")
				
			case .failure(let error):
				self.logger.log(message: "Upload PDF error: \(error)")
			}
		}
	}
	
	@IBAction private func uploadPdfToPostbox() {
		guard let credentials = preferences.credentials(for: Contracts.writeContract.identifier) else {
			self.logger.log(message: "Write contract must be authorized first.")
			return
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let metadata = RawFileMetadataBuilder(mimeType: .applicationPdf, accounts: [String.random(length: 5)])
			.objectTypes([.init(name: "receipt")])
			.tags(["groceries"])
			.reference(["Receipt \(dateFormatter.string(from: Date()))"])
			.build()
		
		guard
			let url = Bundle.main.url(forResource: "uploadExample", withExtension: "pdf"),
			let pdfData = try? Data(contentsOf: url) else {
			
			self.logger.log(message: "Error reading PDF resource file.")
			return
		}
				
		writeDigiMe.writePostbox(data: pdfData, metadata: metadata, credentials: credentials) { result in
			switch result {
			case .success(let refreshedCredentials):
				self.preferences.setCredentials(newCredentials: refreshedCredentials, for: Contracts.writeContract.identifier)
				self.logger.log(message: "Uploaded PDF file.")
				
			case .failure(let error):
				self.logger.log(message: "Upload PDF error: \(error)")
			}
		}
	}
    
    @IBAction private func uploadImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction private func readData() {
        guard let credentials = credentialCache.credentials(for: Contracts.readContract.identifier) else {
            self.logger.log(message: "Read contract must be authorized first.")
            return
        }
        
        readDigiMe.requestDataQuery(credentials: credentials, readOptions: nil) { result in
            switch result {
            case .success(let refreshedCredentials):
                self.credentialCache.setCredentials(refreshedCredentials, for: Contracts.readContract.identifier)
                self.readAllFiles(credentials: refreshedCredentials)
            case .failure(let error):
                self.logger.log(message: "Error requesting data query: \(error)")
            }
        }
    }
    
    @IBAction private func showReadContractDetails() {
        readDigiMe.contractDetails { result in
            switch result {
            case .success(let certificate):
                DispatchQueue.main.async {
                    let startDate = Date.from(year: 2020, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
                    let endDate = Date.from(year: 2023, month: 12, day: 31, hour: 23, minute: 59, second: 59)!
                    var message = "Example where the data request will be always limited to the contract's time range."
                    message += "\n\tRequested dates start: \(startDate) end: \(endDate)"
                    let range = TimeRange.between(from: startDate, to: endDate)
                    let scope = Scope(timeRanges: [range])
                    let readOptions = ReadOptions(limits: nil, scope: scope)
                    let rangeResult = certificate.verifyTimeRange(readOptions: readOptions)
                    switch rangeResult {
                    case .success(let verified):
                        message += "\n\tVerified start: \(verified.startDate) end: \(verified.endDate)"
                    case .failure(let error):
                        message += "\n\tError verifying time range: \(error.description)"
                    }
                    message += "\n\tContract's certificate: \(certificate.json)"
                    self.logger.log(message: message)
                }
            case .failure(let error):
                self.logger.log(message: "\n\tUnable to retrieve contract details: \(error)")
            }
        }
    }
    
    @IBAction private func showWriteContractDetails() {
        writeDigiMe.contractDetails { result in
            switch result {
            case .success(let certificate):
                DispatchQueue.main.async {
                    let startDate = Date.from(year: 2020, month: 1, day: 1, hour: 0, minute: 0, second: 0)!
                    let endDate = Date.from(year: 2023, month: 12, day: 31, hour: 23, minute: 59, second: 59)!
                    var message = "Example where the data request will be always limited to the contract's time range."
                    message += "\n\tRequested dates start: \(startDate) end: \(endDate)"
                    let range = TimeRange.between(from: startDate, to: endDate)
                    let scope = Scope(timeRanges: [range])
                    let readOptions = ReadOptions(limits: nil, scope: scope)
                    let rangeResult = certificate.verifyTimeRange(readOptions: readOptions)
                    switch rangeResult {
                    case .success(let verified):
                        message += "\n\tVerified start: \(verified.startDate) end: \(verified.endDate)"
                    case .failure(let error):
                        message += "\n\tError verifying time range: \(error.description)"
                    }
                    message += "\n\tContract's certificate: \(certificate.json)"
                    self.logger.log(message: message)
                }
            case .failure(let error):
                self.logger.log(message: "\n\tUnable to retrieve contract details: \(error)")
            }
        }
    }
    
    private func readAllFiles(credentials: Credentials) {
        readDigiMe.readAllFiles(credentials: credentials, readOptions: nil) { result in
            switch result {
            case .success(let fileContainer):
                var message = "Downloaded file \(fileContainer.identifier)"
				message += "\n\tFile size: \(fileContainer.data.count) bytes"
                switch fileContainer.metadata {
                case .raw(let metadata):
                    message += "\n\tMime type: \(metadata.mimeType)"
                    message += "\n\tAccounts: \(metadata.accounts.map { $0.accountId })"
                    if let reference = metadata.reference { message += "\n\tReference: \(reference)" }
                    if let tags = metadata.tags { message += "\n\tTags: \(tags)" }
                    if let objectTypes = metadata.objectTypes { message += "\n\tObject types: \(objectTypes.map { $0.name })" }
                default:
                    message += "\n\tUnexpected metadata"
                }
                
                self.logger.log(message: message)
				
				if !fileContainer.data.isEmpty {
					FilePersistentStorage(with: .documentDirectory).store(data: fileContainer.data, fileName: fileContainer.identifier)
				}
                
            case .failure(let error):
                self.logger.log(message: "Error reading file: \(error)")
            }
        } completion: { result in
            switch result {
            case .success(let (fileList, refreshedCredentials)):
                self.credentialCache.setCredentials(refreshedCredentials, for: Contracts.readContract.identifier)
                var message = "Finished reading files:"
                fileList.files?.forEach { message += "\n\t\($0.name)" }
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading files: \(error)")
            }
        }
    }
    
    @IBAction private func deleteUser() {
        // As contracts are linked to the same library, could user either digi.me instance here,
        // as this call disconnects all contracts from library, but need to nullify credentials for both on completion
        let writeCredentials = preferences.credentials(for: Contracts.writeContract.identifier)
        let readCredentials = preferences.credentials(for: Contracts.readContract.identifier)
        guard let credentials = writeCredentials ?? readCredentials  else {
            self.logger.log(message: "At least one contract must be authorized first.")
            return
        }
        
        writeDigiMe.deleteUser(credentials: credentials) { _ in
            self.preferences.clearCredentials(for: Contracts.writeContract.identifier)
			self.preferences.clearCredentials(for: Contracts.readContract.identifier)
            self.logger.reset()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateUI()
            }
            
            return
        }
        
        let isWriteAuthorized = preferences.credentials(for: Contracts.writeContract.identifier) != nil
        self.authorizeWriteButton.isHidden = isWriteAuthorized
        self.uploadPDFButton.isHidden = !isWriteAuthorized
        self.uploadImageButton.isHidden = !isWriteAuthorized
		self.uploadJSONButton.isHidden = !isWriteAuthorized
        
        let isReadAuthorized = preferences.credentials(for: Contracts.readContract.identifier) != nil
        self.authorizeReadButton.isHidden = isReadAuthorized
        self.readDataButton.isHidden = !isReadAuthorized
        
        self.deleteUserButton.isHidden = !isWriteAuthorized && !isReadAuthorized
    }
    
    private func retrieveCurrentContractDetails(completion: @escaping ((Any?) -> Void)) {
        readDigiMe.contractDetails { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(response)
                }
                
                return
            case .failure(let error):
                self.logger.log(message: "Unable to retrieve contract details: \(error)")
            }
        }
    }
}

extension WriteDataViewController: UINavigationControllerDelegate {
}

extension WriteDataViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true) {
            guard
                let image = info[.originalImage] as? UIImage,
                let data = image.jpegData(compressionQuality: 0.2) else {
                self.logger.log(message: "Invalid image selected")
                return
            }
            
            guard let credentials = self.preferences.credentials(for: Contracts.writeContract.identifier) else {
                self.logger.log(message: "Write contract must be authorized first.")
                return
            }
                 
            let fileName = (info[.imageURL] as! URL).lastPathComponent
            let metadata = RawFileMetadataBuilder(mimeType: .imageJpeg, accounts: ["Account1"])
                .objectTypes([.init(name: "purchasedItem")])
                .tags(["groceries"])
                .reference([fileName])
                .build()
            
            self.writeDigiMe.writeDirect(data: data, metadata: metadata, credentials: credentials) { result in
                switch result {
                case .success(let refreshedCredentials):
					self.preferences.setCredentials(newCredentials: refreshedCredentials, for: Contracts.writeContract.identifier)
                    self.logger.log(message: "Uploaded image:\n\(fileName)\n\(image.size) - \(data.count)")

                case .failure(let error):
                    self.logger.log(message: "Upload image error: \(error)")
                }
            }
        }
    }
}

fileprivate struct Receipt: Encodable {
    struct ReceiptItem: Encodable {
        let name = "ItemName"
        let price = "ItemPrice"
    }
    
    let items = [ReceiptItem(), ReceiptItem()]
}
