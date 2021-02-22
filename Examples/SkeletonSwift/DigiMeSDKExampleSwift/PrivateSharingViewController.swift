//
//  PrivateSharingViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import UIKit
import DigiMeSDK

class PrivateSharingViewController: UIViewController {
    
    private var dmeClient: DMEPullClient?
    private var logVC: LogViewController!
    private var configuration: DMEPullConfiguration?
    private var oAuthToken: DMEOAuthToken?
    
    private enum Configuration {
        #warning("REPLACE 'YOUR_APP_ID' with your App ID. Also don't forget to set the app id in CFBundleURLSchemes.")
        static let appId = "YOUR_APP_ID"
        
        #warning("REPLACE 'YOUR_CONTRACT_ID' with your Private Sharing contract ID.")
        static let contractId = "YOUR_CONTRACT_ID"
        
        #warning("REPLACE 'YOUR_P12_PASSWORD' with password provided by digi.me Ltd.")
        static let p12Password = "YOUR_P12_PASSWORD"
        
        #warning("REPLACE 'YOUR_P12_FILE_NAME' with .p12 file name (without the .p12 extension) provided by digi.me Ltd.")
        static let p12FileName = "YOUR_P12_FILE_NAME"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Private Sharing Example"
        
        logVC = LogViewController(frame: UIScreen.main.bounds)
        view.addSubview(logVC)
        view.bringSubviewToFront(logVC)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(runTapped))
        
        logVC.log(message: "Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded.")
        
        navigationController?.isToolbarHidden = false
        let barButtonItems = [UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(zoomOut)),UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(zoomIn))]
        toolbarItems = barButtonItems
    }
    
    @objc func zoomIn() {
        logVC.increaseFontSize()
    }
    
    @objc func zoomOut() {
        logVC.decreaseFontSize()
    }
    
    @objc func runTapped() {
        resetClient()
        updateNavigationBar("Beginning Legacy Flow")
        dmeClient?.authorize { (session, error) in
            
            guard let session = session else {
                if let error = error {
                    self.logVC.log(message: "Authorization failed: " + error.localizedDescription)
                }
                self.clearNavigationBar()
                return
            }
            
            self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
            
            // Uncomment relevant method depending on which you wish to receive.
            self.getAccounts()
            self.getSessionData()
            //self.getSessionFileList()
        }
    }
    
    private func resetClient() {
        // - GET STARTED -
        if let config = DMEPullConfiguration(appId: Configuration.appId, contractId: Configuration.contractId, p12FileName: Configuration.p12FileName, p12Password: Configuration.p12Password) {
            config.debugLogEnabled = true
            dmeClient = nil
            dmeClient = DMEPullClient(configuration: config)
            configuration = config
        }
        else {
            logVC.log(message: "Setup Error: Valid contract details need to be set")
        }
    }
    
    private func clearNavigationBar() {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = nil
            self.title = "Private Sharing Example"
        }
    }
    
    private func updateNavigationBar(_ message: String) {
        if dmeClient != nil {
            DispatchQueue.main.async {
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
                activityIndicator.startAnimating()
                self.title = message
            }
        }
    }
    
    private func getAccounts() {
        updateNavigationBar("Accounts Data")
        dmeClient?.getSessionAccounts { (accounts, error) in
            guard let accounts = accounts else {
                if let error = error {
                    self.logVC.log(message: "Failed to retrieve accounts: " + error.localizedDescription)
                }
                self.clearNavigationBar()
                return
            }
            
            self.logVC.log(message: "Account Content: " + "\(String(describing: accounts.json!))")
        }
    }
    
    private func getSessionData() {
        updateNavigationBar("Session Data")
        dmeClient?.getSessionData(downloadHandler: { (file, error) in
            guard let file = file else {
                if let error = error as NSError?, let fileId = error.userInfo[kFileIdKey] as? String {
                    self.logVC.log(message: "Failed to retrieve content for fileId: " + fileId + " Error: " + error.localizedDescription)
                }
                self.clearNavigationBar()
                return
            }
            
            self.logVC.log(message: "Downloaded file: \(file.fileId), record count: \(file.fileContentAsJSON()?.count ?? 0)")
        }) { (fileList, error) in
            if let error = error {
                self.logVC.log(message: "Client retrieve session data failed: " + error.localizedDescription)
            }
            else {
                self.logVC.log(message: "-------------Finished fetching session data!-------------")
            }
            
            self.clearNavigationBar()
        }
    }
    
    private func getSessionFileList() {
        updateNavigationBar("Session File List")
        dmeClient?.getSessionFileList(updateHandler: { (fileList, fileIds) in
            if !fileIds.isEmpty {
                self.logVC.log(message: "\n\nNew files added or updated in the file List: \(fileIds), accounts: \(fileList.accounts)\n\n")
            }
            else {
                self.logVC.log(message: "\n\nFileList Status: \(fileList.syncStateString), Accounts: \(fileList.accounts)")
            }
        }) { (error) in
            if let error = error {
                self.logVC.log(message: "Client retrieve session file list failed: \(error.localizedDescription)")
            }
            else {
                self.logVC.log(message: "-------------Finished fetching session FileList!-------------")
            }
            
            self.clearNavigationBar()
        }
    }
}
