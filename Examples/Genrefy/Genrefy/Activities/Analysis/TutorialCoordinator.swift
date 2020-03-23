//
//  TutorialCoordinator.swift
//  TFP
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import PopItUp
import SwiftGifOrigin

@objc protocol TutorialCoordinatingDelegate: CoordinatingDelegate {
    func goBack()
}

class TutorialCoordinator: NSObject, ActivityCoordinating {
    
    let identifier: String = UUID().uuidString
    
    var parentCoordinator: Coordinating
    var childCoordinators: [ActivityCoordinating] = []
    
    weak var keyViewController: UIViewController?
    var navigationController: UINavigationController
    
    var serviceType: ServiceType?
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinating) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }

    func childDidFinish(child: ActivityCoordinating, result: Any?) {

    }
    
    func begin() {
        
        guard let serviceType = serviceType else {
            return
        }
        
        let tutorialVewController = TutorialViewController()
        tutorialVewController.serviceType = serviceType
        tutorialVewController.coordinatingDelegate = self
        let viewHeight = tutorialVewController.suggestedHeight()
        let viewWidth = tutorialVewController.suggestedWidth()
        DispatchQueue.main.async {
            self.navigationController.presentPopup(tutorialVewController, animated: true, backgroundStyle: .blur(.dark), constraints: [.width(viewWidth), .height(viewHeight)], transitioning: .zoom, autoDismiss: true, completion: nil)
        }
    }
}

extension TutorialCoordinator: TutorialCoordinatingDelegate {

    func goBack() {
        self.navigationController.dismiss(animated: true) {
            self.parentCoordinator.childDidFinish(child: self, result: nil)
        }
    }
}
