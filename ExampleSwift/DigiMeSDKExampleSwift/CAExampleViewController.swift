//
//  CAExampleViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit
import DigiMeSDK

class CAExampleViewController: UIViewController {
    
    var dmeClient: DMEClient = DMEClient.shared()
    var logVC: LogViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CA Example"
        
        // - GET STARTED -
        
        dmeClient.appId = Constants.appId
        
        dmeClient.privateKeyHex = DMECryptoUtilities.privateKeyHex(fromP12File: Constants.p12FileName, password: Constants.p12Password)
        
        dmeClient.contractId = Constants.CAContractId
        
        logVC = LogViewController(frame: UIScreen.main.bounds)
        view.addSubview(logVC)
        view.bringSubviewToFront(logVC)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(CAExampleViewController.runTapped))
        
        logVC.log(message: "Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded.")
        
        navigationController?.isToolbarHidden = false
        let barButtonItems = [UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(CAExampleViewController.zoomOut)),UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(CAExampleViewController.zoomIn))]
        toolbarItems = barButtonItems
    }
    
    @objc func zoomIn() {
        logVC.increaseFontSize()
    }
    
    @objc func zoomOut() {
        logVC.decreaseFontSize()
    }
    
    @objc func runTapped() {
        logVC.reset()

        dmeClient.authorize { (session, error) in
            
            guard let session = session else {
                if let error = error {
                    self.logVC.log(message: "Authorization failed: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
            
            self.getSessionData()
            self.getAccounts()
        }
    }
    
    func getAccounts() {
        dmeClient.getSessionAccounts { (accounts, error) in
            
            guard let accounts = accounts else {
                if let error = error {
                    self.logVC.log(message: "Failed to retrieve accounts: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "Account Content: " + "\(String(describing: accounts.json!))")
        }
    }
    
    func getSessionData() {
        dmeClient.getSessionData(downloadHandler: { (file, error) in
            guard let file = file else {
                if let error = error as NSError?, let fileId = error.userInfo[kFileIdKey] as? String {
                    self.logVC.log(message: "Failed to retrieve content for fileId: " + fileId + " Error: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "File Content: " + "\(String(describing: file.fileContentAsJSON()))")
        }) { (error) in
            if let error = error {
                self.logVC.log(message: "Client retrieve session data failed: " + error.localizedDescription)
            }
        }
    }
}
