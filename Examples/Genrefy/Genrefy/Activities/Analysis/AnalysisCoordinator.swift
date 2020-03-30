//
//  AnalysisCoordinator.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import UIKit
import SafariServices

class AnalysisCoordinator: NSObject, ActivityCoordinating {
    
    enum BarItemTags: Int {
        case home = 0
        case flagged = 1
        case settings = 2
    }
    
    let identifier: String = UUID().uuidString
    
    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    
    var repository: ImportRepository?
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
    private var tabBarController: UITabBarController
    
    private var pendingPost: TFPost?
    
    private let cache = TFPCache()
    
    private var filteredAccounts: [DMEAccount] = []

    private var postsToDelete: [TFPost] {
        return repository?.tfPosts.filter ({ $0.action == .delete }) ?? []
    }
    
    private lazy var homeViewController: HomeViewController = {
        let homeVC = HomeViewController.instantiate()
        homeVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Results", comment: ""), image: #imageLiteral(resourceName: "homeIcon"), tag: BarItemTags.home.rawValue)
        if let repository = repository {
            homeVC.genreSummaries = repository.orderedGenresSummaries
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
        let dataSource = AccountSelectionDataSource(accounts: repository?.accounts ?? [])
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
        guard let repository = repository  else {
            return
        }
        homeViewController.genreSummaries = repository.orderedGenresSummaries
//        homeViewController.reload()
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
       
        navigationController.popViewController(animated: true)
    }
}

extension AnalysisCoordinator: AccountsViewCoordinatingDelegate {
    func reset() {
        
        if let tfPosts = repository?.tfPosts {
            cache.deleteItems(identifiers: Set(tfPosts.map{ $0.postObject.identifier}))
        }
        
        cache.setOnboarding(value: nil)
        cache.setExistingUser(value: nil)
        
        navigationController.popViewController(animated: true)
        parentCoordinator.childDidFinish(child: self, result: nil)
    }
    
    func viewReceipt() {
        
        do {
            try DigimeService.sharedInstance.dmeClient?.viewReceiptInDMEApp()
        } catch {
            print("digi.me view receipt failed with error: \(error.localizedDescription)")
        }
    }
    
    func openDigime() {
        
        let digimeURL = URL(string: "digime-ca-master://")!
        
        if UIApplication.shared.canOpenURL(digimeURL) {
            UIApplication.shared.open(digimeURL, options: [:], completionHandler: nil)
        }
    }
}
