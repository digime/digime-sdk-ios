//
//  ViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit
import DigiMeSDK

class ViewController: UIViewController {
    
    var dmeClient: DMEClient = DMEClient.shared()
    var fileCount: Int = 0
    var progress: Int = 0
    var logVC: LogViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - GET STARTED -
        
        // - INSERT your App ID here -
        
        dmeClient.appId = "YOUR_APP_ID"
        
        // - REPLACE 'YOUR_P12_PASSWORD' with password provided by Digi.me Ltd
        
        dmeClient.privateKeyHex = DMECryptoUtilities.privateKeyHex(fromP12File: "fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF", password: "YOUR_P12_PASSWORD")
        
        dmeClient.contractId = "fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF"
        
        logVC = LogViewController(frame: UIScreen.main.bounds)
        view.addSubview(logVC)
        view.bringSubviewToFront(logVC)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ViewController.runTapped))
        
        
        logVC.log(message: "Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded.")
        
        navigationController?.isToolbarHidden = false
        let barButtonItems = [UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(ViewController.zoomOut)),UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(ViewController.zoomIn))]
        toolbarItems = barButtonItems
    }
    
    @objc func zoomIn() {
        logVC.increaseFontSize()
    }
    
    @objc func zoomOut() {
        logVC.decreaseFontSize()
    }
    
    @objc func runTapped() {
        
        progress = 0
        logVC.reset()

        dmeClient.authorize { (session, error) in
            
            guard let session = session else {
                
                if let error = error {
                    self.logVC.log(message: "Authorization failed: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
            
            self.getFileList()
            self.getAccounts()
        }
    }
    
    func getAccounts() {
        
        dmeClient.getAccountsWithCompletion { (accounts, error) in
            
            guard let accounts = accounts else {
                
                if let error = error {
                    self.logVC.log(message: "Failed to retrieve accounts: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "Account Content: " + "\(String(describing: accounts.json!))")
            
        }
    }
    
    func getFileList() {
        
        dmeClient.getFileList { (files, error) in
            
            guard let files = files else {
                
                if let error = error {
                    
                    self.logVC.log(message: "Client retrieve fileList failed: " + error.localizedDescription)
                }
                
                return
            }
            
            self.fileCount = files.fileIds.count
            
            for fileId in files.fileIds {
                self.getFileWith(id: fileId)
            }
        }
    }
    
    func getFileWith(id: String) {
        
        dmeClient.getFileWithId(id) { (file, error) in
            
            guard let file = file else {
                
                if let error = error {
                    
                    self.logVC.log(message: "Failed to retrieve content for fileId: " + id + " Error: " + error.localizedDescription)
                }
                
                return
            }
            
            self.progress = self.progress + 1
            
            self.logVC.log(message: "File Content: " + "\(String(describing: file.fileContentAsJSON()))")
            self.logVC.log(message: "--------------------Progress: " + "\(self.progress)" + "/" + "\(self.fileCount)")
        }
    }
}
