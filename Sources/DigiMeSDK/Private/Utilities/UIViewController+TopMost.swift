//
//  UIViewController+TopMost.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import UIKit

extension UIViewController {
    class func topMostViewController() -> UIViewController? {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.topMostViewController()
    }
    
    func topMostViewController() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
        }
        
        return self
    }
}
