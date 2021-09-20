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
    private let cache = AppStateCache()
    let identifier: String = UUID().uuidString
    
    var digimeService: DigiMeService?

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
        parentCoordinator.childDidFinish(child: self, result: nil)
    }
}

// MARK: - IntroCoordinatingDelegate
extension OnboardingCoordinator: IntroCoordinatingDelegate {
    
    func primaryButtonAction(sender: IntroViewController) {
        startConsentRequest()
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
        let scope = digimeService?.lastDayScope()
        let options = ReadOptions(limits: nil, scope: scope)
        
        digimeService?.authorize(readOptions: options, serviceId: 16) { error in
            if let error = error {
                print("digi.me authorization failed with error: \(error)")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.goBack()
                }
                
                return
            }
            
            let importing = ImportingCoordinator(navigationController: self.navigationController, parentCoordinator: self)
            importing.digimeService = self.digimeService
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
