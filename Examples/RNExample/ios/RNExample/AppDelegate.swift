//
//  AppDelegate.swift
//  RNExample
//
//  Created on 18/04/2022.
//  Copyright © 2022 digi.me. All rights reserved.
//

import DigiMeSDK
import Foundation
import React
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var bridge: RCTBridge!
  
  private let eventEmitter = RNExampleEvent.shared
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let jsCodeLocation: URL
    
    jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
    let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: "RNExample", initialProperties: nil, launchOptions: launchOptions)
    let rootViewController = UIViewController()
    rootViewController.view = rootView
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = rootViewController
    self.window?.makeKeyAndVisible()
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    
    let handled = CallbackService.shared().handleCallback(url: url)
    eventEmitter?.log(message: "Consent Access response \(handled ? "successfully received" : "has failed") by RNExample app")
    
    return handled
  }
}
