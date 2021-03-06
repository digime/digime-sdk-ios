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
        // This contract is a one-off contract which allows SDK user to read user's social,
        // financial, health, fitness and music data from 1 June 2017 to 30 June 2018 user over multiple sessions.
        // Each session requires the user's consent (via digi.me app).
        static let contractId = "fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF"
        static let p12Password = "monkey periscope"
        static let p12FileName = "fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF"
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
        if let config = DMEPullConfiguration(appId: AppInfo.appId, contractId: Configuration.contractId, p12FileName: Configuration.p12FileName, p12Password: Configuration.p12Password) {
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
