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
    
    static var configuration: Configuration = {
        // Get YOUR_APP_ID here - https://go.digi.me/developers/register
        // Don't forget to replace YOUR_APP_ID part in URLSchemes in Info.plist
        let appId = "3DuiiOnAurqB3s1HySQUw9MP8D2CkXik" // PROD "qgEUV8iJENRiUkuYF5lLpdsOv7Hp0biy"
        let contractId = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        let privateKey = """
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAvup5e4PbVBVNHtRosFXPPvZCO1kNySe9qo2zI+QnHk7jyK2Y
11MGJiVLkxKp02bGV4NlK5ASptLH22imPSYP/INE1p+XxcSIth1rFZy0b/aWDktM
SB5KMWhIhcmcjLqTuQ8q6qQFDhRVUfBtgbTz64LQ29IHc5EBSN4XzMYwnybbJ6ye
hR5IHoZugRkZA/HZadlPpnygIIN9X2TcuNGaaNh8yum6Jl9xLKpid4CzACTc3Gxg
wdn9o05nzYndnYJqwo2QxreCXifuCZTpjhFW42dqtdRc5YyWFgf1Q8WuaGhBQBNb
P62NLLNUm194IOSUZMl0B8/PYyFjgKmI2M1GEQIDAQABAoIBAE1jstb0vkW5VMe4
hq9kOVxmarawBLyT1Xh7dDCKXakVhZRlel1elFGGMLpviFPfh2sWIj6kakshik5Q
f4KuGTDc7Vyq2NUcM+bOyge6vBHevTkSINvjG2Qnx64j6cfKIfOUSGtRDZOFfoh2
k41OksnW/178JnUcRI8LKE6j0DXS0NcZ//ToJMkYVqCuBqSE0TjX7VXL9Vad9D9v
P4UYjC3ZX8InRCd8akzwhi7x9nZf0zvGtXemEuVOYkOJMLg3ZheYKPpHZgO6Tqhi
tYiwa+YSr6VJ5WvlLFy3LTkwsWg/gdT4JNCV6X/rWrU4JXnJIgdgVgIM+4bwSoFv
I9D7zAECgYEA6vIkmdUOv7SDzgfn4w9MgvePGTYZZDbcYPOM0qhDhY0OJhXMgc6L
hiB6+xvm8HnEfGdbak7eYyTZ/Z7Oe2YxDl9pYGZ3AQAKbDT7liuDQGZWRMUYdGtA
2mRjIi99P8ufeXXLrTwPIk/MPldfd6+dCEZ3mB8sM4T0mSo4kKfdi7ECgYEA0AY/
RdInONgfuzvDf1w9+vsxRaDsWUdiDGRo04nqNlTduxqTSDKCoLMUS6EipANMuOxO
rmxlXfvF7GPaWj4tgrYR0QeJLhk2ScdTe2apGkLgfLnPovaAxPIneaF+xoaSwhSx
PRt4sygYxB6fNQ7KMvofPETPprMt4AC9H5Ve2GECgYAiLcPBVUtl/B7IlEHZuFoL
G3SH2GTtPUXmHMg5xRy9iv2p8LXllGSbyJHbgf2gsjYxWt/joUGc7rl/ueCT9xPf
4WV1DrL1REo/351SBVZ8weZ+7qVWGlw+6Se6y2nPJBI5GzfcJcaV2UH/N7q9sKCJ
mabATJijjg3/UjMUaDdEoQKBgQCRWcwcHRsKvPhu+vM+qlUkaR+kZyy9tQLtZbtZ
E6RzEhlcAtWmPKTJZFdqAM0TjLqu+25+sX6ijKle4uZO5+Mk0dLhG0Le0v77ziqm
rrS5hMEWZT6Pv216Lzkl45GRZbZlpc+xwuAzTnD/l+XmTM87j0kD85CkCc6kFeAP
kW8UAQKBgFv91+8v1pFlPGgbwT3NFM/z9CIbjTl+5wAzvSPO8q2tGXDBO2dpt+2U
XTB5irocXRj2XXn1sMpGBJGf4AKRrIhQNIoAhouh7btYBAD7+eT8SlGQ75wKkaDW
u3W6P+D7xkopNDDFki7IcLyaRzKvXjGf8HeKz0YP+XomHb25Bc3A
-----END RSA PRIVATE KEY-----
"""
        do {
            return try Configuration(appId: appId, contractId: contractId, privateKey: privateKey)
        }
        catch {
            fatalError("Error creating configuration \(error)")
        }
    }()
    
    private var digimeService: DigiMeService
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let dmeClient = AppCoordinator.digiMeClient()
        
        let repository = ImportRepository()
        digimeService = DigiMeService(client: dmeClient, repository: repository)
    }
    
    deinit {
        navigationController.delegate = nil
    }
        
    func begin() {
        
        // Log all levels, including debug.
        DigiMe.logLevels = LogLevel.allCases
        
        digimeService.repository.delegate = self
        digimeService.delegate = self
        
        configureAppearance()
        
        // If have data, go to analysis, otherwise onboard
        if digimeService.isConnected {
            if
                let songData = PersistentStorage.shared.loadData(for: "songs.json"),
                let songs = try? JSONDecoder().decode([Song].self, from: songData) {
                digimeService.repository.process(songs: songs)
            }
            
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
    class func digiMeClient() -> DigiMe {
        return DigiMe(configuration: configuration)
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
        else {
            goToAnalysisCoordinator()
            analysisCoordinator?.repositoryDidUpdateProcessing()
            analysisCoordinator?.repositoryDidFinishProcessing()
        }
    }
}

// MARK: - AnalysisCoordinatorDelegate
extension AppCoordinator: AnalysisCoordinatorDelegate {
    func refreshService() -> DigiMeService {
        let dmeClient = AppCoordinator.digiMeClient()
        let repository = ImportRepository()
        digimeService = DigiMeService(client: dmeClient, repository: repository)
        digimeService.delegate = self
        digimeService.repository.delegate = self
        return digimeService
    }
}
