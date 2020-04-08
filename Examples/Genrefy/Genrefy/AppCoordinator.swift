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
    
    private var digimeService: DigiMeService
    
    private let cache = AppStateCache()

    @objc required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        guard let dmeClient = AppCoordinator.pullClient() else {
            fatalError("Could not create new DMEPullClient")
        }
        
        let repository = ImportRepository()
        digimeService = DigiMeService(client: dmeClient, repository: repository)
    }
    
    deinit {
        navigationController.delegate = nil
    }
        
    @objc func begin() {
        
        digimeService.repository.delegate = self
        digimeService.delegate = self
        
        configureAppearance()
        
        // If have data, go to analysis, otherwise onboard
        if
            let songData = PersistentStorage.shared.loadData(for: "songs.json"),
            let songs = try? JSONDecoder().decode([Song].self, from: songData) {
            digimeService.repository.process(songs: songs)
            goToAnalysisCoordinator()
            analysisCoordinator?.repositoryDidFinishProcessing()
        }
        else {
            goToOnboardingCoordinator()
        }
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
        
        if child is OnboardingCoordinator {
            if let analysisCoordinator = analysisCoordinator {
                analysisCoordinator.repositoryDidFinishProcessing()
            }
        }
        else{
        
            // child is results coordinator
            delegate?.reset()
        }
    }
}

// MARK: - Client Configuration
extension AppCoordinator {
    class func pullClient() -> DMEPullClient? {
        let appId = "qgEUV8iJENRiUkuYF5lLpdsOv7Hp0biy"
        let contractId = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        let p12FileName = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        let p12Password = "digime"
        
        let configuration = DMEPullConfiguration(appId: appId, contractId: contractId, p12FileName: p12FileName, p12Password: p12Password)
        configuration?.debugLogEnabled = true

        guard let config = configuration else {
            fatalError("ERROR: Configuration object not set")
        }
        
        return DMEPullClient(configuration: config)
    }
}

// MARK: - Coordination
extension AppCoordinator {
    func goToOnboardingCoordinator() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController, parentCoordinator: self)
        coordinator.digimeService = digimeService
        childCoordinators.append(coordinator)
        coordinator.begin()
    }
    
    func goToAnalysisCoordinator() {
        cache.setOnboarding(value: true)
        let coordinator = AnalysisCoordinator(navigationController: navigationController, parentCoordinator: self)
        analysisCoordinator = coordinator
        coordinator.delegate = self
        coordinator.digimeService = digimeService
        childCoordinators.append(coordinator)
        coordinator.begin()
    }
    
    func configureAppearance() {
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
    }
}

// MARK: - ImportingRepositoryDelegate
extension AppCoordinator: ImportRepositoryDelegate {
    
    func repositoryDidUpdateProcessing(repository: ImportRepository) {
        guard repository == digimeService.repository else {
            print("Unexpected repository updated")
            return
        }
        
        if let analysisCoordinator = analysisCoordinator {
            analysisCoordinator.repositoryDidUpdateProcessing()
        }
        else {
            goToAnalysisCoordinator()
        }
    }
}

// MARK: - DigiMeServiceDelegate
extension AppCoordinator: DigiMeServiceDelegate {
    func serviceDidFinishImporting() {
        if let analysisCoordinator = analysisCoordinator {
            
            analysisCoordinator.repositoryDidUpdateProcessing()
            analysisCoordinator.repositoryDidFinishProcessing()
        }
    }
}

// MARK: - AnalysisCoordinatorDelegate
extension AppCoordinator: AnalysisCoordinatorDelegate {
    func refreshService() -> DigiMeService {
        guard let dmeClient = AppCoordinator.pullClient() else {
            fatalError("Could not create new DMEPullClient")
        }
        
        let repository = ImportRepository()
        digimeService = DigiMeService(client: dmeClient, repository: repository)
        digimeService.delegate = self
        digimeService.repository.delegate = self
        return digimeService
    }
}
