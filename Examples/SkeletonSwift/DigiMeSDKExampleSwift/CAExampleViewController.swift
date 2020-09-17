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
    var oAuthToken: DMEOAuthToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CA Example"
        
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
        let actionSheet = UIAlertController(title:"digi.me", message:"Choose Consent Access flow", preferredStyle:.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Ongoing Consent Access", style: .default, handler: { (action) -> Void in
            self.runOngoingAccessFlow()
            self.dismiss(animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Legacy Consent Access", style: .default, handler: { (action) -> Void in
            self.runLegacyFlow()
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func resetClient() {
        // - GET STARTED -
        if let config = DMEPullConfiguration(appId: Constants.appId, contractId: Constants.CAContractId, p12FileName: Constants.p12FileName, p12Password: Constants.p12Password) {
            config.debugLogEnabled = true
            dmeClient = nil
            dmeClient = DMEPullClient(configuration: config)
            configuration = config
        }
    }
    
    private func clearNavigationBar() {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = nil
            self.title = "CA Example"
        }
    }
    
    private func updateNavigationBar(_ message: String) {
        DispatchQueue.main.async {
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
            activityIndicator.startAnimating()
            self.title = message
        }
    }
    
    // Consent Access legacy flow
    private func runLegacyFlow() {
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
            
            //Uncomment relevant method depending on which you wish to recieve.
            self.getAccounts()
            self.getSessionData()
            //self.getSessionFileList()
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
    
    // Consent Access ongoing flow
    private func runOngoingAccessFlow() {
        guard
            self.oAuthToken != nil,
            let expiresOn = self.oAuthToken?.expiresOn,
            Date().compare(expiresOn) == .orderedAscending else {
                self.beginOngoingAccess()
                return
        }
        
        self.resumeOngoingAccess()
    }
    
    private func beginOngoingAccess() {
        resetClient()
        updateNavigationBar("Beginning Ongoing Access")
        dmeClient?.authorizeOngoingAccess(completion: { (session, oAuthToken, error) in
            
            guard let session = session else {
                if let error = error {
                    self.logVC.log(message: "Ongoing Access authorization failed: " + error.localizedDescription)
                }
                self.clearNavigationBar()
                return
            }
            
            self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
            self.logVC.log(message: "OAuth access token: " + (oAuthToken?.accessToken ??  "n/a"))
            self.logVC.log(message: "OAuth refresh token: " + (oAuthToken?.refreshToken ?? "n/a"))
            
            self.oAuthToken = oAuthToken
            
            //Uncomment relevant method depending on which you wish to recieve.
            self.getAccounts()
            self.getSessionData()
            //self.getSessionFileList()
        })
    }
    
    func resumeOngoingAccess() {
        resetClient()
        updateNavigationBar("Resuming Ongoing Access")
        dmeClient?.authorizeOngoingAccess(options: nil, oAuthToken: oAuthToken, completion: { session, oAuthToken, error in
            
            guard let session = session else {
                if let error = error {
                    self.logVC.log(message: "Resuming Ongoing Access failed: " + error.localizedDescription)
                }
                self.clearNavigationBar()
                return
            }
            
            self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
            self.logVC.log(message: "OAuth access token: " + (oAuthToken?.accessToken ??  "n/a"))
            self.logVC.log(message: "OAuth refresh token: " + (oAuthToken?.refreshToken ?? "n/a"))
            
            self.oAuthToken = oAuthToken
            
            //Uncomment relevant method depending on which you wish to recieve.
            self.getAccounts()
            self.getSessionData()
            //self.getSessionFileList()
        })
    }
}
