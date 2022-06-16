//
//  AnalysisCoordinator.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit

protocol AnalysisCoordinatorDelegate: AnyObject {
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
    
    private var filteredAccounts: [SourceAccount] = []

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
            let loadedAccounts = try? JSONDecoder().decode([SourceAccount].self, from: persistedData) {
                accounts = loadedAccounts
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
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.lightText], for: .normal)
        appearance.setTitleTextAttributes([.foregroundColor: Theme.highlightColor], for: .selected)
        
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    func repositoryDidFinishProcessing() {
        homeViewController.hideActivityIndicator()
        
        guard let repository = repository else {
            return
        }
        
        if repository.allOrderedGenreSummaries.isEmpty {
            homeViewController.showNoResults()
        }
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
    
    private func displayError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.tabBarController.present(alert, animated: true, completion: nil)
        }
    }
}

extension AnalysisCoordinator: HomeViewControllerDelegate {
    func refreshData() {
        digimeService = delegate?.refreshService()
        let scope = digimeService?.lastDayScope()
        let options = ReadOptions(limits: nil, scope: scope)
        
        digimeService?.authorize(readOptions: options) { error in
            
            if let error = error {
                print("digi.me authorization failed with error: \(error)")
                
                DispatchQueue.main.async {
                    self.repositoryDidFinishProcessing()
                }
                
                return
            }
            
            self.digimeService?.getAccounts()
            self.digimeService?.getSessionData()
        }
    }
}
       
extension AnalysisCoordinator: AccountSelectionCoordinatingDelegate {
    func selectedAccountsChanged(selectedAccounts: [SourceAccount]) {
        // Filter analysis using selected accounts only
        filteredAccounts = selectedAccounts
        if let repository = repository {
            homeViewController.genreSummaries = repository.genreSummariesForAccounts(filteredAccounts)
        }
    }
}

extension AnalysisCoordinator: AccountsViewCoordinatingDelegate {
    func reset() {
        digimeService?.deleteUser { error in
            guard error != nil else {
                self.displayError()
                return
            }
            
            PersistentStorage.shared.reset(fileName: "songs.json")
            
            DispatchQueue.main.async {
                self.navigationController.popViewController(animated: true)
                self.parentCoordinator.childDidFinish(child: self, result: nil)
            }
        }
    }
}
