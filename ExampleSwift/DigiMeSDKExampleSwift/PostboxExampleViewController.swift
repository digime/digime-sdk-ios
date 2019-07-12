//
//  PostboxExampleViewController.swift
//  DigiMeSDKExampleSwift
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit
import DigiMeSDK

class PostboxExampleViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var successfullyPushedToPostbox = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Postbox Example"
    }
    
    @IBAction func createPostbox() {
        
        if successfullyPushedToPostbox {
            
            if DMEClient.shared().canOpenDigiMeApp() {
                let url = URL(string: "digime-ca-master://")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        } else {
            
            let client = DMEClient.shared()
            
            client.postboxDelegate = self
            
            client.appId = Constants.appId
            client.contractId = Constants.postboxContractId
            
            client.createPostbox()
        }
        
    }
    
    func pushData(to postbox: CAPostbox) {
        
        let metadataFileName = "POSTBOXMETADATA"
        let dataFileName = "POSTBOXDATA"
        
        if let metadataPath = Bundle.main.path(forResource: metadataFileName, ofType: "json"),
            let dataPath = Bundle.main.path(forResource: dataFileName, ofType: "json") {
            do {
                
                let metadataToPush = try Data(contentsOf: URL(fileURLWithPath: metadataPath), options: .mappedIfSafe)
                
                let dataToPush = try Data(contentsOf: URL(fileURLWithPath: dataPath), options: .mappedIfSafe)
                
                DMEClient.shared().pushData(to: postbox, metadata: metadataToPush, data: dataToPush) { error in
                    
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
                
            } catch {
                print("JSON files parsing Error: \(error.localizedDescription)")
            }
        }
    }
}

extension PostboxExampleViewController: DMEClientPostboxDelegate {
    
    func postboxCreationFailed(_ error: Error) {
        print("Postbox creation failed with Error: \(error.localizedDescription)")
    }
    
    func postboxCreationSucceeded(_ postbox: CAPostbox) {
        
        print("Postbox creation succeeded")
        
        titleLabel.text = "Sending..."
        subtitleLabel.text = nil
        actionButton.isHidden = true
        
        pushData(to: postbox)
    }
}
