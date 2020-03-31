//
//  ImportingCoordinator.swift
//  Genrefy
//
//  Created on 16/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit

/// Responsible for coordinating the downloading of data from digi.me and notifying the view of progress
class ImportingCoordinator: NSObject, ActivityCoordinating {

    let identifier: String = UUID().uuidString
    
    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
    
    private var oAuthToken: DMEOAuthToken?
    private var fileCount = 0
    private var fileDownloadedCount = 0
    private var repository: ImportRepository
    private var importingViewController: ImportingViewController?
    private let serialQueue = DispatchQueue(label: "ImportSerializationQueue")
    private var failedFileIdKeys = [String: Bool]()
    weak var delegate: ImportRepositoryDelegate?
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.repository = ImportRepository()
        super.init()
        
        if
            let tokenData = UserDefaults.standard.object(forKey: "oAuthToken") as? Data,
            let token = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [DMEOAuthToken.self], from: tokenData) as? DMEOAuthToken {
                oAuthToken = token
        }
        
        repository.delegate = self
    }
    
    func begin() {
        importingViewController = ImportingViewController.instantiate()
        guard let importingViewController = importingViewController else {
            return
        }
        
        getAccounts()
        getFileList()
        navigationController.pushViewController(importingViewController, animated: true)
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
    }
}

extension ImportingCoordinator {
    
    func getAccounts() {
        DigimeService.sharedInstance.dmeClient?.getSessionAccounts(completion: { (accounts, error) in
            if let accounts = accounts {
                self.repository.process(accounts: accounts)
            }

            if let error = error {
                print("digi.me failed to retrieve accounts with error: \(error)")
            }
        })
    }

    func getFileList() {
        DigimeService.sharedInstance.dmeClient?.getSessionData(downloadHandler: { (file, error) in
            if let file = file {
                self.serialQueue.sync {
                    self.repository.process(file: file)
                }
            }

            if let error = error {
                print("digi.me failed to retrieve file with error: \(error)")
            }
        }, completion: { (fileList, error) in
            if let error = error {
                print("digi.me failed to complete getting session data with error: \(error)")
            }

            self.serialQueue.sync {
                self.repositoryDidFinishProcessing()
            }
        })
    }
}

extension ImportingCoordinator: ImportRepositoryDelegate {
    
    func repositoryDidFinishProcessing() {
        self.delegate?.repositoryDidFinishProcessing()
    }
    
    func repositoryDidUpdateProcessing(repository: ImportRepository) {
        delegate?.repositoryDidUpdateProcessing(repository: repository)
    }
}
