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
    var dmeClient: DMEPushClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Postbox Example"
        
        actionButton.addTarget(self, action: #selector(createPostbox), for: .touchUpInside)
    }
    
    @objc func createPostbox() {
        
        if successfullyPushedToPostbox {
            
            dmeClient?.openDMEAppForPostboxImport()
        } else {
            if let configuration = DMEClientConfiguration(appId: Constants.appId, contractId: Constants.postboxContractId, p12FileName: Constants.p12FileName, p12Password: Constants.p12Password) {
                dmeClient = DMEPushClient(configuration: configuration)
            }
            
            dmeClient?.createPostbox { (postbox, error) in
                
                guard let postbox = postbox else {
                    
                    if let error = error {
                        print("Postbox creation failed with Error: \(error.localizedDescription)")
                    }
                    
                    return
                }
                
                print("Postbox creation succeeded")
                
                self.titleLabel.text = "Sending..."
                self.subtitleLabel.text = nil
                self.actionButton.isHidden = true
                
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
