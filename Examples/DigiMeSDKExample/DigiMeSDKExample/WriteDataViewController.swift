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
    
    private var logger: Logger!
    
    private var writeDigiMe: DigiMe!
    private var readDigiMe: DigiMe!
    
    private let writeContract = Contract(name: "Upload data", identifier: "V5cRNEhdXHWqDEM54tZNqBaElDQcfl4v", privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAhMYMWNIeMK34g6uUjUyZlOFSfopWiAvpGH/YL3Gh41LR74MP
        3ikGrxS7BSxU7e8GfoJdk1DP1zl7oj0JV7F7P1GFY/R+SCuynp5TmQ9Ll0pCIkNj
        O2Za1jKV5EWMBOBeiZBWNOUFxaDXKdyuQHLEzxn6R3DYKWI9+a3WbHJH4zNj4o13
        BJsOlIk3N7dHxL73Ao0WlCzkd9b3Czlee4heRUm+oEht+5Ur+jmslotVJmRGOApv
        ffWkyez7uLefSk0p87E4H0I1bTtlLJAKRHj3Jgc6UdTgi6YageZRIBY5Gh50AWyK
        2aYBtTPHqbyAfa8O1HP71d4GcX6dwskRINae+wIDAQABAoIBAGSw4Uo2xwh51v7c
        D4N89PgQTQSEGw1/ot2ejq+kSHZiJ62xQkZj7Jq4aQCKVzo+TDmC2j5PSd/ZyyYF
        jeFASsyBIVzlXSOUaBicz59DFzt76F2dp1Kz0+2fXUdJat+D3I4MtSPWD6OJz8MC
        he+AWjsJY2HsdTIlPATuza9el5/4EIQpbMryKWlisY42jDz59bOHQv5brIgM839Z
        kBXa7FTJuhJ9m8CLMVVxS0Y7SOwVlN7LC0tJRvc9/v+Dc7OaALyufzc6e6ipm3iR
        6znGDzvtyYT36LQnXkeTRQP+bxKqpy1r2+JU3VkMRu3+4hfNnECiuWSXPgMTX3Od
        bzPfA/ECgYEAuPzH8xMSshxoRE4QpJAwYiAxhZsCP8NR5DSE2TfvPdTgXldjfMQt
        3YUbGimky7+47L1QWJM1IIiAt4XbcJthDBul+0UwbJCMN+/hDeSdncHsl/Mz3OiI
        NDtibFTw1iI5dfeAc2Z9K1pzk3tCfnZoLckDO9IlSRdy881fTR4mNHMCgYEAt74T
        GieHXDAzzmd/+8vgTkzdvBPBuNyV3hZ4xjAQ9t0CxdovQw00C9wIy7xUAtWewt43
        EB8TeWEpj/GY3DqeZkgBc6Md+3fJ/GbA1u4AhcFEODKKgcO4k2uBZH2pA9ZxAzW0
        MDlmVElyL0wUR3UrtqWtGMGOauVks/4Sfc2yUVkCgYBOl/dLqtrSmYcjHhesEya7
        SfpATW9TL+TnE/ktYLpghsUcz/wQ0ji6WQb+wpqlhjtHOdedCk4UGGq3jkOBQEKn
        JkgKzYaZWYB5c40mne7pS679j/KE9LaJmoFijWQVVk0bdaA5Z13ewXtBOakymZQB
        f9nD3LDCsRfBxYur9Bc/SQKBgAweCuB0ruaTfzcjeDtAzMAdLZpTqzjnwzJsRPa9
        AMFm/eHSa79+RWpqzmGxP9EYCWpMgVEc24nrsHP/uNb9Pqj8Iqxfm4CT+8wbcqg5
        9ercPgV+v8ejAq8mLdhUuSq5n6ZYilOL1YXFejRITiYQQhu/fVTenufJzQRZwxps
        0E+xAoGBAJvIS8Qpg6s1XJDgNvvbFP0ZkkAoQgCLHYIzvMusXN1PI9ZQUQXec0KZ
        9B/Nk99HD/jCHlONpL+pyGMH5KFP5D9Rx4uTMtv6dpX+4czdOxstonsq68WtgFkU
        xpt9yk2orvtaK/ZtMxiyhRzxW5EPrZkL9xSlfnIxd+M2f4Rqy/po
        -----END RSA PRIVATE KEY-----
        """
    )
    
    private let readContract = Contract(name: "Read uploaded data", identifier: "slA5X9HyO2TnAxBIcRwf1VfpovcD1aQX", privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAnHxDWyjjKXizE6Llo6yMI3xtHSjaPwF7hFQwChwSweqyvBpR
        rozDYKA9OX5yW5AsJYX2AJsPRiD16PdsMwgh/6hgDpPAaAWvwaPVc5oUG0V6I6L6
        apewv5dhE7HbSykIoDZqCpdmHaY4r0H8W8Gck8I3y0ocDuLTbSTfTMDj+9ZPACrw
        kfdh49ZsLDXCobNZvXh5LF1q00G4SD8cyhHTs9MpXCvWIZspawWlC6i8+UmbICw3
        YKcbYSRYTM90/impDWAYPHiyzJNwemgrnJ/M/GyOVLM7tlHuzU/K6ypu9oAjHANl
        L2DuDDjSZg9azTABSXVC1RbjXg+eOodHAqdblQIDAQABAoIBAGnbrf0HBdTSL+JC
        ujIk0ZBX5cBqGGmy6Qm1oeHU5+OCj3KsI0F/O9Qr0f8IyPej6hlgK/Bw9L4uIex9
        JBbJk6ZNEt4JmYlE/4Zw/D59pshkEaH16I0fHJQfJa6bDIwlsA4hgU606IF6JrJ4
        Yuz3ZqKWKgQ9mAmB7CDTZrOXcSK04dEe1t59ba8V56++iRu72avVhjvW87ZxgATN
        UJaQcVLxss0kA6ySP5j1w8VRf8jvNxWY0lPFSmJjaJrB2ovbS1u3vReTkdMbeErK
        cbfl2woGORyCELUEwTG7iI4usFGbgZuU1IVEGvm2zHLE0Jy92sH8N7Spw3/DYxnj
        Fax62AECgYEA1aEEaOjXOA12VlTG0G8OQffZyQzK634amwAQ0f4xpeVBb1Mcilo2
        G+Hf9V+ThSwYGndxtEN4YjFBuxUhjhig8od8ZFiSUPIBzFdtw3w1OHLg68kzTDPC
        +ftQoEgSkE1G3X0csKmr2nL9ibgdBtQCHcFoM5eMXzCmYaFeLCkhLpUCgYEAu4XJ
        5dsPfHE5AAQ6wKn15BflvynVCyf9iVF7O64KGfJaTlPPTMqyt4aNbIiKStTPStZk
        hV/GRqwI8ENjFPpDznIxTiZwkN1YPG2FT8HEAgf8H8826u4yBdEyGDrnvlKtxKli
        h5vdnHCsgaPhYMuDVDaI3/pgfVrWqszXBO7LOQECgYEAqyYiG06Xxk96xDWNRsYC
        fTVtZNZ75+kStaV61FI7QnaGUwMZ9XnKqdHvlGzrCiFGekXBcbMwSjK+P3zxch8n
        KscDEH2pU3JfoG9W/+uN09itfBmooF9D0PTYJmE3hiZzJNWsW5jDlvLTTzeTAbpu
        q5ocumCq1ERsuAEJKoYVEHUCgYANvLpSpV6YDi9Pyf+H16uUvw9slqLtw0s2gQqX
        D6PbzL5C2K7qADthaHD5z3LaEobxA42vm5mJ2dZ5y2X5xm+rMwBbqkM6yYxKOPe4
        JQi34V/d8K8kPLjbZjzWO5J4hdQHASWfq5JrgHGSua+sCJyhUbFrPwtMg5gQQRtL
        WDb5AQKBgEycWssIPCULSSEinr1AD3FMczrZsLlGJWITp3af7IqeI2UQ9Bm8XSxX
        Pbx/llXLPRze9YT857XcrM/8w/F14iQDq+6wOu1tCoriT006QnIjMKGoJftXipTO
        AFUT+vgwhNxAy5/JN536S0Atg3TCcOzppsFg0i0GCoyhBqY5OWyn
        -----END RSA PRIVATE KEY-----
        """
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Write Data Example"
        
        logger = Logger(textView: loggerTextView)
        logger.log(message: "This is where log messages appear.")
        
        do {
            let writeConfig = try Configuration(appId: AppInfo.appId, contractId: writeContract.identifier, privateKey: writeContract.privateKey)
            writeDigiMe = DigiMe(configuration: writeConfig)
            
            let readConfig = try Configuration(appId: AppInfo.appId, contractId: readContract.identifier, privateKey: readContract.privateKey)
            readDigiMe = DigiMe(configuration: readConfig)
            
            updateUI()
        }
        catch {
            logger.log(message: "Unable to configure digi.me SDK: \(error)")
        }
    }
    
    @IBAction private func authorizeWriteContract() {
        writeDigiMe.authorize { error in
            if let error = error {
                self.logger.log(message: "Authorization failed: \(error)")
                return
            }
            
            self.updateUI()
        }
    }
    
    @IBAction private func authorizeReadContract() {
        readDigiMe.authorize(linkToContractWithId: writeContract.identifier) { error in
            if let error = error {
                self.logger.log(message: "Authorization failed: \(error)")
                return
            }
            
            self.updateUI()
        }
    }
    
    @IBAction private func uploadJson() {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let metadata = RawFileMetadataBuilder(mimeType: .applicationJson, accounts: ["Account1"])
                .objectTypes([.init(name: "receipt")])
                .tags(["groceries"])
                .reference(["Receipt \(dateFormatter.string(from: Date()))"])
                .build()
            
            let jsonData = try JSONEncoder().encode(Receipt())
            
            writeDigiMe.write(data: jsonData, metadata: metadata) { result in
                switch result {
                case .success:
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
                    self.logger.log(message: "Upload Error: \(error.localizedDescription)")
                }
            }
        }
        catch {
            logger.log(message: "JSON files parsing Error: \(error.localizedDescription)")
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
        readDigiMe.readFiles(readOptions: nil) { result in
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
            case .success(let fileList):
                var message = "Finished reading files:"
                fileList.files?.forEach { message += "\n\t\($0.name)" }
                self.logger.log(message: message)
                
            case .failure(let error):
                self.logger.log(message: "Error reading files: \(error)")
            }
        }
    }
    
    @IBAction private func deleteUser() {
        // Could user either digi.me instance here as it disconnects all contracts from library
        writeDigiMe.deleteUser { _ in
            self.logger.reset()
            self.updateUI()
        }
        
        readDigiMe.deleteUser { _ in
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
        
        let isWriteAuthorized = self.writeDigiMe.isConnected
        self.authorizeWriteButton.isHidden = isWriteAuthorized
        self.uploadJsonButton.isHidden = !isWriteAuthorized
        self.uploadImageButton.isHidden = !isWriteAuthorized
        
        let isReadAuthorized = self.readDigiMe.isConnected
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
                 
            let fileName = (info[.imageURL] as! URL).lastPathComponent
            let metadata = RawFileMetadataBuilder(mimeType: .imageJpeg, accounts: ["Account1"])
                .objectTypes([.init(name: "purchasedItem")])
                .tags(["groceries"])
                .reference([fileName])
                .build()
            
            self.writeDigiMe.write(data: data, metadata: metadata) { result in
                switch result {
                case .success:
                    self.logger.log(message: "Uploaded image:\n\(fileName)\n\(image.size) - \(data.count)")

                case .failure(let error):
                    self.logger.log(message: "Upload Error: \(error.localizedDescription)")
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
