//
//  ViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit
import DigiMeSDK

#if TIMING
import MessageUI
#endif

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var dmeClient: DMEClient = DMEClient.shared()
    var fileCount: Int = 0
    var progress: Int = 0
    var logVC: LogViewController!
    
#if TIMING
    var totalTimingInterval: CFAbsoluteTime!
    var filesDownloadTimingInterval: CFAbsoluteTime!
    var pickerView: UIPickerView!
    var selectedContract: ContractType = .oneoff
    var selectedGroup: GroupType = .social
#endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dmeClient.delegate = self
        
        dmeClient.appId = ConsentAccessLoggingKeys.productionEnvironment ? ConsentAccessLoggingKeys.productionAppId : ConsentAccessLoggingKeys.developmentAppId
        let p12FileName = ConsentAccessLoggingKeys.productionEnvironment ? "timings-prod" : "timings-dev"
        dmeClient.privateKeyHex = DMECryptoUtilities.privateKeyHex(fromP12File: p12FileName, password: "digime")

        logVC = LogViewController(frame: UIScreen.main.bounds)
        view.addSubview(logVC)
        view.bringSubview(toFront: logVC)
        
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
#if TIMING
        showChooseContractAlert()
#else
        dmeClient.authorize()
        progress = 0
        logVC.reset()
#endif
    }
    
#if TIMING
    func showChooseContractAlert() {

        let message = "Please Select the Contract"
        
        let string = NSMutableAttributedString(string: message)
        let range = NSRange(location: 0, length: message.count)
        string.addAttribute(.foregroundColor, value: UIColor.black, range: range)
        string.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .bold), range: range)

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.setValue(string, forKey: "attributedTitle")
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 40, width: 280, height: 160))
        pickerView.dataSource = self
        pickerView.delegate = self
        alert.view.addSubview(pickerView)
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.width / 1.5)
        alert.view.addConstraint(height);
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default , handler: { (UIAlertAction) in
            self.run(groupType: self.selectedGroup, contractType: self.selectedContract)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func run(groupType: GroupType, contractType: ContractType) {
        totalTimingInterval = CFAbsoluteTimeGetCurrent()
        var contractId: String!
        
        if ConsentAccessLoggingKeys.productionEnvironment {
            contractId = contractType == .oneoff ? groupType.oneoffProdContractId : groupType.ongoingProdContractId
        }
        else {
            contractId = contractType == .oneoff ? groupType.oneoffDevContractId : groupType.ongoingDevContractId
        }
        
        dmeClient.contractId = contractId
        dmeClient.authorize()
        progress = 0
        logVC.reset()
    }
#endif
}

extension ViewController: DMEClientDelegate {
    
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
    
    func clientFailed(toRetrieveFileList error: Error) {
        logVC.log(message: "Client retrieve fileList failed: " + error.localizedDescription)
    }
    
    func clientRetrievedFileList(_ files: CAFiles) {
        
        fileCount = files.fileIds.count
#if TIMING
        filesDownloadTimingInterval = CFAbsoluteTimeGetCurrent()
#endif
        for fileId in files.fileIds {
            dmeClient.getFileWithId(fileId)
        }
    }
    
    func fileRetrieved(_ file: CAFile) {
        progress += 1
        logVC.log(message: "--------------------Progress: " + "\(progress)" + "/" + "\(fileCount)")
//        logVC.log(message: "File Content: " + "\(String(describing: file.json!))")
#if TIMING
        performPostProcessingIfAppropriate()
#endif
    }
    
    func fileRetrieveFailed(_ fileId: String, error: Error) {
        logVC.log(message: "Failed to retrieve content for fileId: " + fileId + " Error: " + error.localizedDescription)
        fileCount -= 1
        performPostProcessingIfAppropriate()
    }
    
    func accountsRetrieved(_ accounts: CAAccounts) {
        if accounts.json != nil {
            logVC.log(message: "Account Content: " + "\(String(describing: accounts.json!))")
        }
    }
    
    func accountsRetrieveFailed(_ error: Error) {
        logVC.log(message: "Failed to retrieve accounts: " + error.localizedDescription)
    }
}

extension ViewController {
#if TIMING
    func performPostProcessingIfAppropriate() {

        if fileCount == progress {
            
            dmeClient.logs.setValue("ios", forKey:ConsentAccessLoggingKeys.debugPlatform)
            
            let elapsedFilesDownload = CFAbsoluteTimeGetCurrent() - filesDownloadTimingInterval
            let elapsedFilesDownloadString = String(format: "%.2f", elapsedFilesDownload)
            dmeClient.logs.setValue(elapsedFilesDownloadString, forKey: ConsentAccessLoggingKeys.timingDataGetAllFiles)
            
            let elapsed = CFAbsoluteTimeGetCurrent() - totalTimingInterval
            let elapsedString = String(format: "%.2f", elapsed)
            dmeClient.logs.setValue(elapsedString, forKey: ConsentAccessLoggingKeys.timingTotal)
            
            dmeClient.logs.setValue(dmeClient.appId, forKey: ConsentAccessLoggingKeys.debugAppId)
            dmeClient.logs.setValue(dmeClient.contractId, forKey: ConsentAccessLoggingKeys.debugContractId)
            
            logVC.log(message: dmeClient.logs.debugDescription)
            exportLogs()
        }
    }

    func exportLogs() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MMMM.yyyy.HH.mm.ss.SSS"
        let fileName = "ca.debug.logging.\(formatter.string(from: Date())).csv"
        var csvText = "Key,Value\n"
        
        for (key, value) in Array(dmeClient.logs).sorted(by: { ($0.key as AnyObject).compare($1.key as! String, options: .caseInsensitive) == .orderedAscending })  {
            csvText.append(contentsOf: "\(key),\(value)\n")
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                
                if MFMailComposeViewController.canSendMail() {
                    let data = try NSData(contentsOf: fileURL) as Data
                    
                    let emailController = MFMailComposeViewController()
                    emailController.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
                    emailController.setToRecipients([])
                    emailController.setSubject("Consent Access timings data export")
                    emailController.setMessageBody("Hi,\n\nThe .csv data export is attached\n\n\nSent from the digi.me Consent Access Skeleton app: http://digi.me", isHTML: false)
                    
                    emailController.addAttachmentData(data, mimeType: "text/csv", fileName: fileName)
                    
                    present(emailController, animated: true, completion: nil)
                }
            }
            catch let error as NSError {
                print("Error writing debug file \(error.localizedDescription)")
            }
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
#endif
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return GroupType.allValues.count
        }
        else {
            return ContractType.allValues.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let group = GroupType(rawValue: row)
            return group?.title
        }
        else {
            let contract = ContractType(rawValue: row)
            return contract?.title
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGroup = GroupType(rawValue:pickerView.selectedRow(inComponent: 0))!
        selectedContract = ContractType(rawValue: pickerView.selectedRow(inComponent: 1))!
    }
}
