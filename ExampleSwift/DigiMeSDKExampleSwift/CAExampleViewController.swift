//
//  CAExampleViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import UIKit
import DigiMeSDK

class CAExampleViewController: UIViewController {
    
    var dmeClient: DMEPullClient?
    var logVC: LogViewController!
    var configuration: DMEPullConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CA Example"
        
        // - GET STARTED -
        configuration = DMEPullConfiguration(appId: Constants.appId, contractId: Constants.CAContractId, p12FileName: Constants.p12FileName, p12Password: Constants.p12Password)
        configuration?.debugLogEnabled = true
        
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
        guard let config = configuration else {
            print("ERROR: Configuration object not set")
            return
        }
        
        dmeClient = nil
        dmeClient = DMEPullClient(configuration: config)
        
        logVC.reset()
        
        dmeClient?.authorize { (session, error) in
            
            if let digiMeVersion = self.dmeClient?.metadata[kDMEDigiMeVersion] as? String {
                self.logVC.log(message: "digi.me App Version: " + digiMeVersion)
            }
            
            guard let session = session else {
                if let error = error {
                    self.logVC.log(message: "Authorization failed: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
            
            //Uncomment relevant method depending on which you wish to recieve.
            //self.getSessionData()
            self.getSessionFileList()
            self.getAccounts()
        }
    }
    
    func getAccounts() {
        dmeClient?.getSessionAccounts { (accounts, error) in
            
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
        title = "Session Data"
        
        dmeClient?.getSessionData(downloadHandler: { (file, error) in
            guard let file = file else {
                if let error = error as NSError?, let fileId = error.userInfo[kFileIdKey] as? String {
                    self.logVC.log(message: "Failed to retrieve content for fileId: " + fileId + " Error: " + error.localizedDescription)
                }
                
                return
            }
            
            self.logVC.log(message: "Downloaded file: \(file.fileId), record count: \(file.fileContentAsJSON()?.count ?? 0)")
        }) { (fileList, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.logVC.log(message: "Client retrieve session data failed: " + error.localizedDescription)
                }
                else {
                    self.logVC.log(message: "-------------Finished fetching session data!-------------")
                }
            }
        }
    }
    
    func getSessionFileList() {
        title = "Session FileList"
        
        dmeClient?.getSessionFileList(updateHandler: { (fileList, fileIds) in
            if !fileIds.isEmpty {
                self.logVC.log(message: "\n\nNew files added or updated in the file List: \(fileIds), accounts: \(fileList.accounts)\n\n")
            }
            else {
                self.logVC.log(message: "\n\nFileList Status: \(fileList.syncStateString), Accounts: \(fileList.accounts)")
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.logVC.log(message: "Client retrieve session file list failed: \(error.localizedDescription)")
                }
                else {
                    self.logVC.log(message: "-------------Finished fetching session FileList!-------------")
                }
                
                self.title = nil
            }
        }
    }
}
