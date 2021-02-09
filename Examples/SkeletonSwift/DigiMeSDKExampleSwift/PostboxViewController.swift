//
//  PostboxViewController.swift
//  DigiMeSDKExampleSwift
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit
import DigiMeSDK

class PostboxViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private var successfullyPushedToPostbox = false
    private var dmeClient: DMEPushClient?
    private var ongoingPostbox: DMEOngoingPostbox?
    
    private enum Configuration {
        #warning("REPLACE 'YOUR_APP_ID' with your App ID. Also don't forget to set the app id in CFBundleURLSchemes.")
        static let appId = "YOUR_APP_ID"
        
        #warning("REPLACE 'YOUR_CONTRACT_ID' with your Postbox contract ID.")
        static let contractId = "YOUR_CONTRACT_ID"
        
        #warning("REPLACE 'YOUR_P12_PASSWORD' with password provided by digi.me Ltd.")
        static let p12Password = "YOUR_P12_PASSWORD"
        
        #warning("REPLACE 'YOUR_P12_FILE_NAME' with .p12 file name (without the .p12 extension) provided by digi.me Ltd.")
        static let p12FileName = "YOUR_P12_FILE_NAME"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Postbox Example"
        
        actionButton.addTarget(self, action: #selector(createPostbox), for: .touchUpInside)
    }
    
    @objc func createPostbox() {
        
        if successfullyPushedToPostbox {
            
            dmeClient?.openDMEAppForPostboxImport()
        } else {
            guard let configuration = DMEPushConfiguration(appId: Configuration.appId, contractId: Configuration.contractId, p12FileName: Configuration.p12FileName, p12Password: Configuration.p12Password) else {
                return
            }
            
            dmeClient = DMEPushClient(configuration: configuration)
            
            dmeClient?.createPostbox { (postbox, error) in
                
                guard let postbox = postbox else {
                    
                    if let error = error {
                        print("Postbox creation failed with Error: \(error.localizedDescription)")
                    }
                    
                    return
                }
                
                print("Postbox creation succeeded")
                
                DispatchQueue.main.async {
                    self.titleLabel.text = "Sending..."
                    self.subtitleLabel.text = nil
                    self.actionButton.isHidden = true
                }
                
                self.pushData(to: postbox)
            }
        }
    }
    
    func pushData(to postbox: DMEPostbox) {
        
        let metadataFileName = "POSTBOXMETADATA"
        let dataFileName = "POSTBOXDATA"
        
        if let metadataPath = Bundle.main.path(forResource: metadataFileName, ofType: "json"),
            let dataPath = Bundle.main.path(forResource: dataFileName, ofType: "json") {
            do {
                
                let metadataToPush = try Data(contentsOf: URL(fileURLWithPath: metadataPath), options: .mappedIfSafe)
                
                let dataToPush = try Data(contentsOf: URL(fileURLWithPath: dataPath), options: .mappedIfSafe)
                
                dmeClient?.pushData(to: postbox, metadata: metadataToPush, data: dataToPush) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Upload Error: \(error.localizedDescription)")
                            
                            self.successfullyPushedToPostbox = false
                            
                            self.titleLabel.text = "Get a copy of your latest shopping receipt to your digi.me library"
                            self.subtitleLabel.text = "Please ensure you have the digi.me application installed."
                            self.actionButton.isHidden = false
                            self.actionButton.setTitle("SEND ME THE RECEIPT", for: .normal)
                        }
                        else {
                            print("Pushing data to Postbox succeeded")
                            
                            self.successfullyPushedToPostbox = true
                            
                            self.titleLabel.text = "All done!"
                            self.subtitleLabel.text = "Your purchase receipt has been sent, please check your digi.me library."
                            self.actionButton.isHidden = false
                            self.actionButton.setTitle("OPEN DIGI.ME", for: .normal)
                        }
                    }
                }
            } catch {
                print("JSON files parsing Error: \(error.localizedDescription)")
            }
        }
    }
}
