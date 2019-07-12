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
  var fileCount: Int = 0
  var progress: Int = 0
  var logVC: LogViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "CA Example"

    dmeClient.authorizationDelegate = self
    dmeClient.downloadDelegate = self
        
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
    dmeClient.authorize()
    logVC.reset()
  }
}

extension CAExampleViewController: DMEClientAuthorizationDelegate {
  
  func sessionCreated(_ session: CASession) {
    logVC.log(message: "Session created: " + session.sessionKey)
  }
  
  func sessionCreateFailed(_ error: Error) {
    logVC.log(message: "Session created: " + error.localizedDescription)
  }
  
  func authorizeSucceeded(_ session: CASession) {
    logVC.log(message: "Authorization Succeeded for session: " + session.sessionKey)
    
    dmeClient.getAccounts()
    dmeClient.getFileList()
  }
  
  func authorizeDenied(_ error: Error) {
    logVC.log(message: "Authorization denied: " + error.localizedDescription)
  }
  
  func authorizeFailed(_ error: Error) {
    logVC.log(message: "Authorization failed: " + error.localizedDescription)
  }
}

extension CAExampleViewController: DMEClientDownloadDelegate {
  func clientFailed(toRetrieveFileList error: Error) {
    logVC.log(message: "Client retrieve fileList failed: " + error.localizedDescription)
  }
  
  func clientRetrievedFileList(_ files: CAFiles) {
    
    fileCount = files.fileIds.count
    
    for fileId in files.fileIds {
      dmeClient.getFileWithId(fileId)
    }
  }
  
  func fileRetrieved(_ file: CAFile) {
    progress = progress + 1
    
    logVC.log(message: "File Content: " + "\(String(describing: file.json!))")
    logVC.log(message: "--------------------Progress: " + "\(progress)" + "/" + "\(fileCount)")
  }
  
  func fileRetrieveFailed(_ fileId: String, error: Error) {
    logVC.log(message: "Failed to retrieve content for fileId: " + fileId + " Error: " + error.localizedDescription)
  }
  
  func accountsRetrieved(_ accounts: CAAccounts) {
    logVC.log(message: "Account Content: " + "\(String(describing: accounts.json!))")
  }
  
  func accountsRetrieveFailed(_ error: Error) {
    logVC.log(message: "Failed to retrieve accounts: " + error.localizedDescription)
  }
}
