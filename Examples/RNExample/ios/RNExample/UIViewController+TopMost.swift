//
//  UIViewController+TopMost.swift
//  RNExample
//
//  Created on 18/04/2022.
//  Copyright © 2022 digi.me. All rights reserved.
//

import UIKit

@objc extension UIViewController {
  /// Finds the top-most view controller in the view hierarchy that sits above the key window's root view controller
  ///
  /// - Returns: The top-most view controller above the key window's root view controller
  public class func topMost() -> UIViewController? {
    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
      return nil
    }
    
    return rootViewController.topMost()
  }
  
  /// Finds the top-most view controller in the view hierarchy that sits above this view controller
  ///
  /// - Returns: The top-most view controller above this view controller, or self if none above
  public func topMost() -> UIViewController {
    if let navigationController = self as? UINavigationController {
      return navigationController.visibleViewController?.topMost() ?? self
    }
    
    if let tabBarController = self as? UITabBarController {
      return tabBarController.selectedViewController?.topMost() ?? self
    }
    
    return presentedViewController?.topMost() ?? self
  }
}
