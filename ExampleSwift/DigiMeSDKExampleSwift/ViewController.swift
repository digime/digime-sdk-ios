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
    
    dmeClient.delegate = self
    
    // - GET STARTED -
    
    // - INSERT your App ID here -
    
    dmeClient.appId = "YOUR_APP_ID"
    
    // - REPLACE 'YOUR_P12_PASSWORD' with password provided by Digi.me Ltd
    
    dmeClient.privateKeyHex = DMECryptoUtilities.privateKeyHex(fromP12File: "CA_RSA_PRIVATE_KEY", password: "YOUR_P12_PASSWORD")
    
    dmeClient.contractId = "gzqYsbQ1V1XROWjmqiFLcH2AF1jvcKcg"
    
    self.logVC = LogViewController(frame: UIScreen.main.bounds)
    self.view.addSubview(logVC)
    self.view.bringSubview(toFront: logVC)
    
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ViewController.runTapped))
    
    
    self.logVC.log(message: "Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded.")
    
    
    self.navigationController?.isToolbarHidden = false
    let barButtonItems = [UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(ViewController.zoomOut)),UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(ViewController.zoomIn))]
    self.toolbarItems = barButtonItems
  }
  
  @objc func zoomIn() {
    self.logVC.increaseFontSize()
  }
  
  @objc func zoomOut() {
    self.logVC.decreaseFontSize()
  }
  
  @objc func runTapped() {
    self.dmeClient.authorize()
    self.logVC.reset()
  }
}

extension ViewController: DMEClientDelegate {
  
  func sessionCreated(_ session: CASession) {
    self.logVC.log(message: "Session created: " + session.sessionKey)
  }
  
  func sessionCreateFailed(_ error: Error) {
    self.logVC.log(message: "Session created: " + error.localizedDescription)
  }
  
  func authorizeSucceeded(_ session: CASession) {
    self.logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
    
    self.dmeClient.getAccounts()
    self.dmeClient.getFileList()
  }
  
  func authorizeDenied(_ error: Error) {
    self.logVC.log(message: "Authorization denied: " + error.localizedDescription)
  }
  
  func authorizeFailed(_ error: Error) {
    self.logVC.log(message: "Authorization failed: " + error.localizedDescription)
  }
  
  func clientFailed(toRetrieveFileList error: Error) {
    self.logVC.log(message: "Client retrieve fileList failed: " + error.localizedDescription)
  }
  
  func clientRetrievedFileList(_ files: CAFiles) {
    
    self.fileCount = files.fileIds.count
    
    for fileId in files.fileIds {
      dmeClient.getFileWithId(fileId)
    }
  }
  
  func fileRetrieved(_ file: CAFile) {
    self.progress = self.progress + 1
    
    self.logVC.log(message: "File Content: " + "\(String(describing: file.json!))")
    self.logVC.log(message: "--------------------Progress: " + "\(self.progress)" + "/" + "\(self.fileCount)")
  }
  
  func fileRetrieveFailed(_ fileId: String, error: Error) {
    self.logVC.log(message: "Failed to retrieve content for fileId: " + fileId + " Error: " + error.localizedDescription)
  }
  
  func accountsRetreived(_ accounts: CAAccounts) {
    self.logVC.log(message: "Account Content: " + "\(String(describing: accounts.json!))")
  }
  
  func accountsRetrieveFailed(_ error: Error) {
    self.logVC.log(message: "Failed to retrieve accounts: " + error.localizedDescription)
  }
}
