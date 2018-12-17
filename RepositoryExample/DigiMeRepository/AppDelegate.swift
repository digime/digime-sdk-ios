//
//  AppDelegate.swift
//  DigiMeRepository
//
//  Created on 07/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return DMEClient.shared().open(url, options: options)
    }

}
