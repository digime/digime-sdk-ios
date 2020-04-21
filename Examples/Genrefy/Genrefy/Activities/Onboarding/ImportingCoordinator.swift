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
    
    private var importingViewController: ImportingViewController?
    weak var delegate: ImportRepositoryDelegate?
    var digimeService: DigiMeService?
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        super.init()
    }
    
    func begin() {
        
        importingViewController = ImportingViewController.instantiate()
        guard let importingViewController = importingViewController else {
            return
        }
        
        digimeService?.getAccounts()
        digimeService?.getSessionData()
        navigationController.pushViewController(importingViewController, animated: true)
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
    }
}
