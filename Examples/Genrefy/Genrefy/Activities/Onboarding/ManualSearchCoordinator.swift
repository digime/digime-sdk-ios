//
//  ManualSearchCoordinator.swift
//  TFP
//
//  Created on 10/12/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class ManualSearchCoordinator: NSObject, ActivityCoordinating {
    
    struct Result {
        let didTapInstall: Bool
    }
    
    let identifier: String = UUID().uuidString
    
    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
    
    private var username: String?
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func begin() {
        let vc = ManualSearchViewController.instantiate()
        vc.coordinatingDelegate = self
        navigationController.pushViewController(vc, animated: true)
        keyViewController = vc
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
        
        guard
            child is TutorialCoordinator,
            let username = username else {
                parentCoordinator.childDidFinish(child: self, result: nil)
                return
        }
    
        // hand off search to ViewController
        (keyViewController as? ManualSearchViewController)?.performSearchForUsername(username)
        
        return
    }
}

extension ManualSearchCoordinator {
    private func delegateToTutorialCoordinator() {
        let tutorialCoordinator = TutorialCoordinator(navigationController: navigationController, parentCoordinator: self)
        tutorialCoordinator.keyViewController = keyViewController
        tutorialCoordinator.serviceType = .twitter
        childCoordinators.append(tutorialCoordinator)
        tutorialCoordinator.begin()
    }
}

extension ManualSearchCoordinator: ManualSearchCoordinatingDelegate {
    func goBack() {
        parentCoordinator.childDidFinish(child: self, result: Result(didTapInstall: false))
    }
    
    func didEnterUsername(_ username: String) {
        self.username = username
        
        delegateToTutorialCoordinator()
    }
    
    func didTapInstall() {
        parentCoordinator.childDidFinish(child: self, result: Result(didTapInstall: true))
    }
}
