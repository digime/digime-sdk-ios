//
//  OnboardingCoordinator.swift
//  DigiMe
//
//  Created on 06/04/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SVProgressHUD
import UIKit

class OnboardingCoordinator: NSObject, ActivityCoordinating {
    struct Result {
        let data: ImportRepository
    }
    
    enum Constants {
        static let privacyPolicy = "https://www.digi.me/privacy-policy"
    }
    
    private let cache = AppStateCache()
    let identifier: String = UUID().uuidString
    weak var delegate: ImportRepositoryDelegate?

    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
        
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func begin() {
        let vc = newHomeViewController()
        navigationController.pushViewController(vc, animated: false)
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
        navigationController.popViewController(animated: true)
    }
}

// MARK: - IntroCoordinatingDelegate
extension OnboardingCoordinator: IntroCoordinatingDelegate {
    
    func primaryButtonAction(sender: IntroViewController) {
        startConsentRequest()
    }
    
    func secondaryButtonAction(sender: IntroViewController) {
        let popupModalTransition = PopupModalTransition()
        popupModalTransition.delegate = self
        let promiseModalViewController = PromiseModalViewController()
        promiseModalViewController.coordinatingDelegate = self
        promiseModalViewController.transitionManager = popupModalTransition
        promiseModalViewController.modalPresentationStyle = .custom
        navigationController.present(promiseModalViewController, animated: true, completion: nil)
    }
}

// MARK: - PromiseModalCoordinatingDelegate
extension OnboardingCoordinator: PromiseModalCoordinatingDelegate {
    func privacyPolicyButtonAction() {
        guard let url = URL(string: Constants.privacyPolicy) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}

// MARK: - PopupModalTransitionDelegate
extension OnboardingCoordinator: PopupModalTransitionDelegate {
    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    var popupSize: CGSize? {
        return nil
    }
}

// MARK: - ConsentRequestCoordinatingDelegate
extension OnboardingCoordinator: ConsentRequestCoordinatingDelegate {
    func goBack() {
        navigationController.popViewController(animated: true)
    }
    
    func startConsentRequest() {
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Authorizing...")
        SVProgressHUD.setContainerView(navigationController.topViewController?.view)
        
        authorize()
    }
    
    func authorize() {
        let scope = DMEScope()
        let objects = [DMEServiceObjectType(identifier: 406)]
        let services = [DMEServiceType(identifier: 19, objectTypes: objects)]
        let groups = [DMEServiceGroup(identifier: 5, serviceTypes: services)]
        scope.serviceGroups = groups
        scope.timeRanges = [DMETimeRange.last(1, unit: .day)]
        
        DigimeService.sharedInstance.dmeClient?.authorizeOngoingAccess(scope: scope, oAuthToken: nil) { (session, oAuthToken, error) in
            
            guard let _ = session else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.goBack()
                }
                if let error = error {
                    print("digi.me authorization failed with error: \(error)")
                } else {
                    print("digi.me authorization failed")
                }
                return
            }
 
            if
                let oAuthToken = oAuthToken,
                let tokenData = try? NSKeyedArchiver.archivedData(withRootObject: oAuthToken, requiringSecureCoding: true) {
                    UserDefaults.standard.set(tokenData, forKey:"oAuthToken")
            }
            
            let importing = ImportingCoordinator(navigationController: self.navigationController, parentCoordinator: self)
            importing.delegate = self
            self.childCoordinators.append(importing)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                importing.begin()
                self.cache.setConsentDate(consentDate: Date())
            }
        }
    }
}

extension OnboardingCoordinator {
    
    func newHomeViewController() -> IntroViewController {
        let vc = IntroViewController.instantiate()
        vc.useCase = HomeViewControllerUseCase()
        vc.coordinatingDelegate = self
        return vc
    }
}

// MARK: - ImportRepositoryDelegate
extension OnboardingCoordinator: ImportRepositoryDelegate {
    func repositoryDidFinishProcessing() {
        delegate?.repositoryDidFinishProcessing()
    }
    
    func repositoryDidUpdateProcessing(repository: ImportRepository) {
        delegate?.repositoryDidUpdateProcessing(repository: repository)
    }
}
