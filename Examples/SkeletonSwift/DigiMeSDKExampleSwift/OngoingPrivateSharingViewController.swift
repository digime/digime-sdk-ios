//
//  OngoingPrivateSharingViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import UIKit
import DigiMeSDK

class OngoingPrivateSharingViewController: UIViewController {
    
    private var dmeClient: DMEPullClient?
    private var logVC: LogViewController!
    private var configuration: DMEPullConfiguration?
    private let kAuthTokenKey = "ongoing_private_sharing_token"
    
    // Ideally this would be stored somewhere more secure, like the keychain.
    // However for this example, we are just using UserDefaults.
    private var oAuthToken: DMEOAuthToken? {
        get {
            guard let data = UserDefaults.standard.object(forKey: kAuthTokenKey) as? Data else {
                return nil
            }
            
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: DMEOAuthToken.self, from: data)
        }
        
        set {
            if let newValue = newValue,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) {
                UserDefaults.standard.setValue(data, forKey: kAuthTokenKey)
            }
            else {
                UserDefaults.standard.removeObject(forKey: kAuthTokenKey)
            }
        }
    }
    
    private enum Configuration {
        // This contract is a one-off contract which allows SDK user to read user's Spotify
        // data from the past 6 months user over multiple sessions.
        // User consent is required just once (via digi.me app).
        static let contractId = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        static let p12Password = "digime"
        static let p12FileName = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ongoing Private Sharing Example"
        
        logVC = LogViewController(frame: UIScreen.main.bounds)
        view.addSubview(logVC)
        view.bringSubviewToFront(logVC)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(runTapped))
        
        logVC.log(message: "Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded.")
        
        navigationController?.isToolbarHidden = false
        let barButtonItems = [UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(zoomOut)),UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(zoomIn))]
        toolbarItems = barButtonItems
        
        let alert = UIAlertController(title:"digi.me", message:"See our Genrefy example app for a more detailed example of ongoing private sharing.", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
        }))

        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func zoomIn() {
        logVC.increaseFontSize()
    }
    
    @objc func zoomOut() {
        logVC.decreaseFontSize()
    }
    
    @objc func runTapped() {
        self.runOngoingAccessFlow()
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
            self.title = "Ongoing Private Sharing Example"
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
            self.logVC.log(message: "\n\nPlease press 'Start' to request data again.\n\nAlternatively, try relaunching the app and starting again.\n\nIn either case you will see that it doesn't open the digi.me application to check permission.\n")
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
                self.logVC.log(message: "\n\nPlease press 'Start' to request data again.\n\nAlternatively, try relaunching the app and starting again.\n\nIn either case you will see that it doesn't open the digi.me application to check permission.\n")
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
                self.logVC.log(message: "\n\nPlease press 'Start' to request data again.\n\nAlternatively, try relaunching the app and starting again.\n\nIn either case you will see that it doesn't open the digi.me application to check permission.\n")
            }

            self.clearNavigationBar()
        }
    }
    
    // Consent Access ongoing flow
    private func runOngoingAccessFlow() {
        guard
            let expiresOn = oAuthToken?.expiresOn,
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
            
            // Uncomment relevant method depending on which you wish to receive.
            self.getAccounts()
            self.getSessionData()
//            self.getSessionFileList()
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
            
            // Uncomment relevant method depending on which you wish to receive.
            self.getAccounts()
            self.getSessionData()
//            self.getSessionFileList()
        })
    }
}
