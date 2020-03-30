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
        homeVC.swearPosts = repository?.tfPosts
        homeVC.allPosts = repository?.objects
        homeVC.coordinatingDelegate = self
        return homeVC
    }()
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }

    func begin() {
        
        // If don't require a tab controller and only want to show a single view controller,
        // then just need to do the following and wire up any delegates from that view controller:
//        let homeVC = HomeViewController.instantiate()
//        navigationController.pushViewController(tabBarController, animated: true)
        
        let accountsVC = AccountsViewController.instantiate()
        let dataSource = AccountSelectionDataSource(accounts: repository?.accounts ?? [])
        dataSource.coordinatingDelegate = self
        let presenter = AccountSelectionPresenter(dataSource: dataSource)
        accountsVC.presenter = presenter
        accountsVC.coordinatingDelegate = self
        accountsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: #imageLiteral(resourceName: "settingsIcon"), tag: BarItemTags.settings.rawValue)
        
        let deleteVC = FlaggedViewController.instantiate()
        deleteVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Flagged", comment: ""), image: #imageLiteral(resourceName: "flaggedIcon"), tag: BarItemTags.flagged.rawValue)
        deleteVC.coordinatingDelegate = self
//        let settingsVC = SettingsViewController.instantiate()
//        settingsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: #imageLiteral(resourceName: "settingsIcon"), tag: 2)
        
        let controllers = [homeViewController, deleteVC, accountsVC]
        tabBarController.viewControllers = controllers
        tabBarController.delegate = self
        tabBarController.tabBar.barTintColor = UIColor.black
        tabBarController.tabBar.tintColor = Theme.highlightColor
        let appearance = UITabBarItem.appearance(whenContainedInInstancesOf: [UITabBarController.self])
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightText], for: .normal)
        appearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Theme.highlightColor], for: .selected)
        
        updateBadge(value: postsToDelete.count, for: deleteVC.tabBarItem)
        
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    func repositoryDidFinishProcessing() {
        homeViewController.hideActivityIndicator()
    }
    
    func repositoryDidUpdateProcessing() {
        guard
            let repository = repository,
            !repository.orderedGenresSummaries.isEmpty else {
                return
        }
        
        let entries = repository.orderedGenresSummaries
        PersistentStorage.shared.store(genres: entries)
        homeViewController.genreSummaries = entries
        homeViewController.reload()
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
       
        if child is TutorialCoordinator {
            guard
                let post = pendingPost,
                let serviceType = post.postObject.serviceType else {
                    return
            }
            cache.setTutorial(service: serviceType, didShow: true)
            showSafariViewController(post: post)
        }
        else {
            navigationController.popViewController(animated: true)
        }
    }
}

extension AnalysisCoordinator: AccountSelectionCoordinatingDelegate {
    func selectedAccountsChanged(selectedAccounts: [DMEAccount]) {
        // Filter analysis using selected accounts only
        filteredAccounts = selectedAccounts
        homeViewController.allPosts = repository?.objectsForAccounts(filteredAccounts)
        homeViewController.swearPosts = repository?.postsForAccounts(selectedAccounts)
        homeViewController.reload()
    }
}

extension AnalysisCoordinator: HomeViewCoordinatingDelegate {
    
    func didSelect(word: String) {
        
        // Filter posts for that word
        let matchingPosts = repository?.tfPosts.filter { $0.matchedWord == word && $0.action == .undecided }
        
        if let posts = matchingPosts {
            // Go to details
            let swearDetailsVC = SwearDetailsViewController.instantiate()
            swearDetailsVC.coordinatingDelegate = self
            swearDetailsVC.posts = posts
            navigationController.pushViewController(swearDetailsVC, animated: true)
        }
    }
}

extension AnalysisCoordinator: DetailCoordinatingDelegate {
    func didSelectPost(post: TFPost) {
        
        guard let serviceType = post.postObject.serviceType else {
            return
        }
        
        pendingPost = post
        
        if cache.didShowTutorial(service: serviceType) {
            showSafariViewController(post: post)
        }
        else {
            showTutorial(serviceType: serviceType)
        }
    }
    
    func showSafariViewController(post: TFPost?) {
        guard let post = post else {
            return
        }
        
        let postUrlString = post.postObject.postUrl
        if let postUrl = URL(string: postUrlString) {
            let safari = SFSafariViewController(url: postUrl)
            navigationController.present(safari, animated: true, completion: nil)
            
            post.action = .confirmed
            self.cache.addItem(identifier: post.postObject.identifier, action: post.action)
            didUpdateFlagged()
        }
    }
    
    func showTutorial(serviceType: ServiceType) {
        let coordinator = TutorialCoordinator(navigationController: navigationController, parentCoordinator: self)
        childCoordinators.append(coordinator)
        coordinator.serviceType = serviceType
        coordinator.begin()
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
        
        if let homeVC = tabBarController.viewControllers?.first as? HomeViewController {
            homeVC.reload()
        }
    }
    
    func didUpdateFlagged() {
        guard let flaggedVC = tabBarController.tabBar.items?[BarItemTags.flagged.rawValue] else {
            return
        }
        
        updateBadge(value: postsToDelete.count, for: flaggedVC)
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

extension AnalysisCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let deletePostsViewController = viewController as? FlaggedViewController else {
            return
        }
        
        guard !postsToDelete.isEmpty else {
                print("No posts selected for deletion")
                return
        }
        
        deletePostsViewController.postsToDelete = postsToDelete
    }
}

private extension AnalysisCoordinator {
    func updateBadge(value: Int, for tabBarItem: UITabBarItem) {
        guard value > 0 else {
            tabBarItem.badgeValue = nil
            return
        }
        
        tabBarItem.badgeValue = "\(value)"
    }
}
