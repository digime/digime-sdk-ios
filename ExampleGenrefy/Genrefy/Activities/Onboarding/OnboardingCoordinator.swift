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
    
    private let cache = TFPCache()
    let identifier: String = UUID().uuidString
    weak var delegate: ImportRepositoryDelegate?

    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    lazy var onboardingViewControllers: [IntroViewController] = {
        return [newHomeViewController(),newIntroViewController(),newProcessViewController(),newHowtoViewController(),newCALaunchViewController()]
    }()
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
        
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func begin() {
        let vc = newIntroPageViewController()
        navigationController.pushViewController(vc, animated: false)

        // let homeVC = EditListViewController.instantiate()
        // homeVC.coordinatingDelegate = self
        // navigationController.pushViewController(homeVC, animated: true)
        
        // let homeVC = HomeViewController.instantiate()
        // homeVC.coordinatingDelegate = self
        // navigationController.pushViewController(homeVC, animated: true)
        
        // let homeVC = SwearDetailsViewController.instantiate()
        // homeVC.coordinatingDelegate = self
        // navigationController.pushViewController(homeVC, animated: true)
    }
    
    func childDidFinish(child: ActivityCoordinating, result: Any?) {
        removeChild(child)
        
        navigationController.popViewController(animated: true)
        (keyViewController as? NoAppConsentRequestViewController)?.isDigiMeInstalled = DMEAppCommunicator.shared().canOpenDMEApp()
        
        if
            let result = result as? ManualSearchCoordinator.Result,
            result.didTapInstall {
            startConsentRequest()
        }
    }
}

// MARK: - IntroCoordinatingDelegate
extension OnboardingCoordinator: IntroCoordinatingDelegate {
    
    func skipOnboarding(sender: IntroViewController) {
        if let pageViewController = sender.parent as? IntroPageViewController  {
            pageViewController.skipOnboarding()
        }
    }
    
    func primaryButtonAction(sender: IntroViewController) {
        if sender.useCase is CALaunchViewControllerUseCase {
            startConsentRequest()
        }
        else {
            guard let nextVC = viewController(after: sender) else {
                parentCoordinator.childDidFinish(child: self, result: nil)
                return
            }
            
            if let pageViewController = sender.parent as? IntroPageViewController  {
                pageViewController.setViewControllers([nextVC], direction: .forward, animated: true)
                updatePageControl(for: pageViewController)
            }
            
        }
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
        DigimeService.sharedInstance.dmeClient?.authorizeOngoingAccess(completion: { (session, oAuthToken, error) in
            
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
            
            let importing = ImportingCoordinator(navigationController: self.navigationController, parentCoordinator: self)
            importing.delegate = self
            self.childCoordinators.append(importing)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                importing.begin()
                self.cache.setConsentDate(consentDate: Date())
            }
        })
    }
    
    func startTwitterDemo() {
        let manualCoordinator = ManualSearchCoordinator(navigationController: navigationController, parentCoordinator: self)
        childCoordinators.append(manualCoordinator)
        manualCoordinator.begin()
    }
}

extension OnboardingCoordinator {
    
    func newIntroPageViewController() -> IntroPageViewController {
        let vc = IntroPageViewController()
        vc.coordinatingDelegate = self
        return vc
    }
    
    func newHomeViewController() -> IntroViewController {
        let vc = IntroViewController.instantiate()
        vc.useCase = HomeViewControllerUseCase()
        vc.coordinatingDelegate = self
        return vc
    }
    
    func newIntroViewController() -> IntroViewController {
        let vc = IntroViewController.instantiate()
        vc.useCase = IntroductionViewControllerUseCase()
        vc.coordinatingDelegate = self
        return vc
    }
    
    func newProcessViewController() -> IntroViewController {
        let vc = IntroViewController.instantiate()
        vc.useCase = ProcessViewControllerUseCase()
        vc.coordinatingDelegate = self
        return vc
    }
    
    func newHowtoViewController() -> IntroViewController {
        let vc = IntroViewController.instantiate()
        vc.useCase = HowtoViewControllerUseCase()
        vc.coordinatingDelegate = self
        return vc
    }
    
    func newCALaunchViewController() -> IntroViewController {
        let vc = IntroViewController.instantiate()
        vc.useCase = CALaunchViewControllerUseCase()
        vc.coordinatingDelegate = self
        return vc
    }
}

// MARK: - IntroFlowDelegate
extension OnboardingCoordinator: IntroFlowDelegate {
    
    func viewController(after vc: IntroViewController) -> IntroViewController? {
        
        guard let viewControllerIndex = onboardingViewControllers.index(of: vc) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < onboardingViewControllers.count else {
            return nil
        }
        
        return onboardingViewControllers[nextIndex]
    }
    
    func viewController(before vc: IntroViewController) -> IntroViewController? {
        
        guard let viewControllerIndex = onboardingViewControllers.index(of: vc) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard
            previousIndex >= 0,
            onboardingViewControllers.count > previousIndex else {
                return nil
        }
        
        return onboardingViewControllers[previousIndex]
    }
    
    func updatePageControl(for pageViewController: IntroPageViewController) {
        
        if let pageContentViewController = pageViewController.viewControllers?[0] as? IntroViewController {
            pageViewController.pageControl.currentPage = onboardingViewControllers.index(of: pageContentViewController)!
        }
        
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
