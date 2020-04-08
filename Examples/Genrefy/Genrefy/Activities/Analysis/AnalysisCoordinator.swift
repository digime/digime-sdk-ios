//
//  AnalysisCoordinator.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit

protocol AnalysisCoordinatorDelegate: class {
    func refreshService() -> DigiMeService
}

class AnalysisCoordinator: NSObject, ActivityCoordinating {
    
    enum BarItemTags: Int {
        case home = 0
        case settings = 1
    }
    
    let identifier: String = UUID().uuidString
    
    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    
    var repository: ImportRepository? {
        return digimeService?.repository
    }
    
    var digimeService: DigiMeService?
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
    private var tabBarController: UITabBarController
    weak var delegate: AnalysisCoordinatorDelegate?
        
    private let cache = AppStateCache()
    
    private var filteredAccounts: [DMEAccount] = []

    private lazy var homeViewController: HomeViewController = {
        let homeVC = HomeViewController.instantiate()
        homeVC.coordinatingDelegate = self
        homeVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Results", comment: ""), image: #imageLiteral(resourceName: "homeIcon"), tag: BarItemTags.home.rawValue)
        if let repository = repository {
            homeVC.genreSummaries = repository.allOrderedGenreSummaries
        }

        return homeVC
    }()
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }

    func begin() {
        let accountsVC = AccountsViewController.instantiate()
        var accounts = repository?.accounts ?? []
    
        if
            accounts.isEmpty,
            let persistedData = PersistentStorage.shared.loadData(for: "accounts.json"),
            let persistedDict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(persistedData) as? [AnyHashable: Any],
            let restoredAccounts = persistedDict,
            let identifier = restoredAccounts["consentid"] as? String {
                let deserialized = DMEAccounts(fileId: identifier, json: restoredAccounts)
                accounts = deserialized.accounts ?? []
        }
        
        let dataSource = AccountSelectionDataSource(accounts: accounts)
        dataSource.coordinatingDelegate = self
        let presenter = AccountSelectionPresenter(dataSource: dataSource)
        accountsVC.presenter = presenter
        accountsVC.coordinatingDelegate = self
        accountsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: #imageLiteral(resourceName: "settingsIcon"), tag: BarItemTags.settings.rawValue)
        
        let controllers = [homeViewController, accountsVC]
        tabBarController.viewControllers = controllers
        tabBarController.tabBar.barTintColor = UIColor.black
        tabBarController.tabBar.tintColor = Theme.highlightColor
        let appearance = UITabBarItem.appearance(whenContainedInInstancesOf: [UITabBarController.self])
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightText], for: .normal)
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Theme.highlightColor], for: .selected)
        
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    func repositoryDidFinishProcessing() {
        homeViewController.hideActivityIndicator()
    }
    
    func repositoryDidUpdateProcessing() {
        guard let repository = repository else {
            return
        }
        
        homeViewController.genreSummaries = repository.allOrderedGenreSummaries

        let songs = repository.recentSongs
        do {
            let songData = try JSONEncoder().encode(songs)
            PersistentStorage.shared.store(data: songData, fileName: "songs.json")
        }
        catch {
            print("Unable to encode song data")
        }
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)

        navigationController.popViewController(animated: true)
    }
}

extension AnalysisCoordinator: HomeViewControllerDelegate {
    func refreshData() {
        digimeService = delegate?.refreshService()
        let scope = digimeService?.lastDayScope()
        let token = digimeService?.loadToken()
        let client = digimeService?.dmeClient
        client?.authorizeOngoingAccess(scope: scope, oAuthToken: token) { (session, oAuthToken, error) in
            
            guard let _ = session else {
                if let error = error {
                    print("digi.me authorization failed with error: \(error)")
                } else {
                    print("digi.me authorization failed")
                }
                return
            }
            
            self.digimeService?.saveToken(oAuthToken)
            self.digimeService?.getAccounts()
            self.digimeService?.getSessionData()
            self.cache.setConsentDate(consentDate: Date())
        }
    }
}
       
extension AnalysisCoordinator: AccountSelectionCoordinatingDelegate {
    func selectedAccountsChanged(selectedAccounts: [DMEAccount]) {
        // Filter analysis using selected accounts only
        filteredAccounts = selectedAccounts
        if let repository = repository {
            homeViewController.genreSummaries = repository.genreSummariesForAccounts(filteredAccounts)
        }
    }
}

extension AnalysisCoordinator: AccountsViewCoordinatingDelegate {
    func reset() {
        
        PersistentStorage.shared.reset(fileName: "songs.json")
        
        cache.setOnboarding(value: nil)
        cache.setExistingUser(value: nil)
        
        navigationController.popViewController(animated: true)
        parentCoordinator.childDidFinish(child: self, result: nil)
    }
    
    func viewReceipt() {
        
        do {
            try digimeService?.dmeClient.viewReceiptInDMEApp()
        } catch {
            print("digi.me view receipt failed with error: \(error.localizedDescription)")
        }
    }
}
