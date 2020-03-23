//
//  AppCoordinator.swift
//  DigiMe
//
//  Created on 06/04/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import UIKit

class AppCoordinator: NSObject, ApplicationCoordinating {
    var delegate: ApplicationCoordinatorDelegate?
    
    let identifier: String = UUID().uuidString
    
    var window: UIWindow?
    var navigationController: UINavigationController
    
    var childCoordinators: [ActivityCoordinating] = []
    
    var analysisCoordinator: AnalysisCoordinator?
    
    private let cache = TFPCache()

    @objc required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        navigationController.delegate = nil
    }
        
    @objc func begin() {
        
        configureAppearance()
        
        // If have data, go to analysis, otherwise onboard
        goToOnboardingCoordinator()
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
        // child is results coordinator
        delegate?.reset()
        // navigationController.popToRootViewController(animated: true)
        // goToOnboardingCoordinator()
    }
}

extension AppCoordinator {
    
    func goToOnboardingCoordinator() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController, parentCoordinator: self)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.begin()
    }
    
    func configureAppearance() {
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
    }
}

extension AppCoordinator: ImportRepositoryDelegate {
    
    func repositoryDidFinishProcessing() {
        if let analysisCoordinator = analysisCoordinator {
            analysisCoordinator.repositoryDidFinishProcessing()
        }
    }
    
    func repositoryDidUpdateProcessing(repository: ImportRepository) {
        if let analysisCoordinator = analysisCoordinator {
            analysisCoordinator.repository = repository
            analysisCoordinator.repositoryDidUpdateProcessing()
        }
        else {
            cache.setOnboarding(value: true)
            let coordinator = AnalysisCoordinator(navigationController: navigationController, parentCoordinator: self)
            analysisCoordinator = coordinator
            childCoordinators.append(coordinator)
            coordinator.repository = repository
            coordinator.begin()
        }
    }
}
