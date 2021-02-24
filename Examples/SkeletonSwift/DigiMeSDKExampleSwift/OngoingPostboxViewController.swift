//
//  OngoingPostboxViewController.swift
//  DigiMeSDKExampleSwift
//
//  Copyright © 2021 digi.me. All rights reserved.
//

import UIKit
import DigiMeSDK

class OngoingPostboxViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private var dmeClient: DMEPushClient?
    private var ongoingPostbox: DMEOngoingPostbox?
    
    private enum Configuration {
        #warning("REPLACE 'YOUR_APP_ID' with your App ID. Also don't forget to set the app id in CFBundleURLSchemes.")
        static let appId = "YOUR_APP_ID"
        
        #warning("REPLACE example contract ID with your ongoing Postbox contract ID.")
        static let contractId = "V5cRNEhdXHWqDEM54tZNqBaElDQcfl4v"
        
        #warning("REPLACE example .p12 password with password provided by digi.me Ltd.")
        static let p12Password = "digime"
        
        #warning("REPLACE example .p12 file name with .p12 file name provided by digi.me Ltd.")
        static let p12FileName = "V5cRNEhdXHWqDEM54tZNqBaElDQcfl4v"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ongoing Postbox Example"
        
        actionButton.addTarget(self, action: #selector(createPostbox), for: .touchUpInside)
        self.actionButton.setTitle("SEND ME A RECEIPT", for: .normal)
    }
    
    @objc func createPostbox() {
        
        guard let configuration = DMEPushConfiguration(appId: Configuration.appId, contractId: Configuration.contractId, p12FileName: Configuration.p12FileName, p12Password: Configuration.p12Password) else {
            return
        }
        
        dmeClient = DMEPushClient(configuration: configuration)
        
        dmeClient?.authorizeOngoingPostbox(withExisting: ongoingPostbox) { (postbox, error) in
            
            guard let postbox = postbox else {
                
                if let error = error {
                    print("Postbox creation failed with Error: \(error.localizedDescription)")
                }
                
                return
            }
            
            print("Postbox creation succeeded")
            self.ongoingPostbox = postbox
            
            DispatchQueue.main.async {
                self.titleLabel.text = "Sending..."
                self.subtitleLabel.text = nil
                self.actionButton.isHidden = true
            }
            
            self.pushData(to: postbox)
        }
    }
    
    func pushData(to postbox: DMEOngoingPostbox) {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let metadata = Metadata(reference: ["Receipt \(dateFormatter.string(from: Date()))"])
            let metadataToPush = try JSONEncoder().encode(metadata)
            
            let dataToPush = try JSONEncoder().encode(Receipt())
            
            // Update title in metadata
            
            dmeClient?.pushData(to: postbox, metadata: metadataToPush, data: dataToPush) { updatedPostbox, error in
                if let error = error {
                    print("Upload Error: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = "Get a copy of your latest shopping receipt to your digi.me library"
                        self.subtitleLabel.text = "Please ensure you have the digi.me application installed."
                        self.actionButton.isHidden = false
                        self.actionButton.setTitle("SEND ME A RECEIPT", for: .normal)
                    }
                }
                else {
                    print("Pushing data to Postbox succeeded")
                    self.ongoingPostbox = updatedPostbox
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = "All done!"
                        self.subtitleLabel.text = "Your purchase receipt has been sent, please check your digi.me library."
                        self.actionButton.isHidden = false
                        self.actionButton.setTitle("SEND ME ANOTHER RECEIPT", for: .normal)
                    }
                }
                
                
            }
        } catch {
            print("JSON files parsing Error: \(error.localizedDescription)")
        }
    }
}

fileprivate struct Metadata: Encodable {
    struct Account: Encodable {
        let accountId: String
    }
    
    struct ObjectType: Encodable {
        let name: String
    }
    
    let accounts = [Account(accountId: "accountId")]
    let mimeType = "application/json"
    let objectTypes = [ObjectType(name: "receipt")]
    let reference: [String]
    let tags = ["groceries"]
}


fileprivate struct Receipt: Encodable {
    struct ReceiptItem: Encodable {
        let name = "ItemName"
        let price = "ItemPrice"
    }
    
    let items = [ReceiptItem(), ReceiptItem()]
}
