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
    @IBOutlet private var uploadJsonButton: UIButton!
    @IBOutlet private var uploadImageButton: UIButton!
    @IBOutlet private var authorizeReadButton: UIButton!
    @IBOutlet private var readDataButton: UIButton!
    @IBOutlet private var deleteUserButton: UIButton!
    @IBOutlet private var loggerTextView: UITextView!
    
	private let credentialCache = CredentialCache()
	
    private var logger: Logger!
    private var writeDigiMe: DigiMe!
    private var readDigiMe: DigiMe!

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
            let metadata = RawFileMetadataBuilder(mimeType: .applicationJson, accounts: ["Account1"])
                .objectTypes([.init(name: "receipt")])
                .tags(["groceries"])
                .reference(["Receipt \(dateFormatter.string(from: Date()))"])
                .build()
            
            let jsonData = try JSONEncoder().encode(Receipt())
            
            writeDigiMe.write(data: jsonData, metadata: metadata, credentials: credentials) { result in
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
                    self.logger.log(message: "Upload Error: \(error)")
                }
            }
        }
        catch {
            logger.log(message: "JSON files parsing Error: \(error)")
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
    
    private func readAllFiles(credentials: Credentials) {
        readDigiMe.readAllFiles(credentials: credentials, readOptions: nil) { result in
            switch result {
            case .success(let fileContainer):
                var message = "Downloaded file \(fileContainer.identifier)"
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
        let writeCredentials = credentialCache.credentials(for: Contracts.writeContract.identifier)
        let readCredentials = credentialCache.credentials(for: Contracts.readContract.identifier)
        guard let credentials = writeCredentials ?? readCredentials  else {
            self.logger.log(message: "At least one contract must be authorized first.")
            return
        }
        
        writeDigiMe.deleteUser(credentials: credentials) { _ in
            self.credentialCache.setCredentials(nil, for: Contracts.writeContract.identifier)
            self.credentialCache.setCredentials(nil, for: Contracts.readContract.identifier)
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
        
        let isWriteAuthorized = credentialCache.credentials(for: Contracts.writeContract.identifier) != nil
        self.authorizeWriteButton.isHidden = isWriteAuthorized
        self.uploadJsonButton.isHidden = !isWriteAuthorized
        self.uploadImageButton.isHidden = !isWriteAuthorized
        
        let isReadAuthorized = credentialCache.credentials(for: Contracts.readContract.identifier) != nil
        self.authorizeReadButton.isHidden = isReadAuthorized
        self.readDataButton.isHidden = !isReadAuthorized
        
        self.deleteUserButton.isHidden = !isWriteAuthorized && !isReadAuthorized
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
            
            guard let credentials = self.credentialCache.credentials(for: Contracts.writeContract.identifier) else {
                self.logger.log(message: "Write contract must be authorized first.")
                return
            }
                 
            let fileName = (info[.imageURL] as! URL).lastPathComponent
            let metadata = RawFileMetadataBuilder(mimeType: .imageJpeg, accounts: ["Account1"])
                .objectTypes([.init(name: "purchasedItem")])
                .tags(["groceries"])
                .reference([fileName])
                .build()
            
            self.writeDigiMe.write(data: data, metadata: metadata, credentials: credentials) { result in
                switch result {
                case .success(let refreshedCredentials):
                    self.credentialCache.setCredentials(refreshedCredentials, for: Contracts.writeContract.identifier)
                    self.logger.log(message: "Uploaded image:\n\(fileName)\n\(image.size) - \(data.count)")

                case .failure(let error):
                    self.logger.log(message: "Upload Error: \(error)")
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
