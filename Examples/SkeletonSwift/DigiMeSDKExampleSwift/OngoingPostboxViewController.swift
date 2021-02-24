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
    @IBOutlet weak var relaunchLabel: UILabel!
    
    private let kPostboxKey = "ongoing_postbox"
    private var dmeClient: DMEPushClient?
    
    // Ideally this would be stored somewhere more secure, like the keychain.
    // However for this example, we are just using UserDefaults.
    private var ongoingPostbox: DMEOngoingPostbox? {
        get {
            guard let data = UserDefaults.standard.object(forKey: kPostboxKey) as? Data else {
                return nil
            }
            
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: DMEOngoingPostbox.self, from: data)
        }
        
        set {
            if let newValue = newValue,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) {
                UserDefaults.standard.setValue(data, forKey: kPostboxKey)
            }
            else {
                UserDefaults.standard.removeObject(forKey: kPostboxKey)
            }
        }
    }
    
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
        actionButton.setTitle(ongoingPostbox != nil ? "SEND ANOTHER RECEIPT" : "SEND ME A RECEIPT", for: .normal)
            
        
        relaunchLabel.isHidden = true
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
                self.actionButton.isEnabled = false
                self.actionButton.setTitle("Sending...", for: .normal)
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
            
            dmeClient?.pushData(to: postbox, metadata: metadataToPush, data: dataToPush) { updatedPostbox, error in
                if let error = error {
                    print("Upload Error: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = "Get a copy of your latest shopping receipt to your digi.me library"
                        self.subtitleLabel.text = "Please ensure you have the digi.me application installed."
                        self.actionButton.isEnabled = true
                        self.actionButton.setTitle("SEND ME A RECEIPT", for: .normal)
                    }
                }
                else {
                    print("Pushing data to Postbox succeeded")
                    self.ongoingPostbox = updatedPostbox
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = "All done!"
                        self.subtitleLabel.text = "Your purchase receipt has been sent, please check your digi.me library."
                        self.actionButton.isEnabled = true
                        self.actionButton.setTitle("SEND ANOTHER RECEIPT", for: .normal)
                        self.relaunchLabel.isHidden = false
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
