//
//  AppDelegate.swift
//  DigiMeSDKExample
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeHealthKit
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set up URLCache
        let memoryCapacity = 500 * 1024 * 1024 // 500 MB
        let diskCapacity = 500 * 1024 * 1024   // 500 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDataPath")
        URLCache.shared = cache

        let exampleString = "application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {" // ASCII characters

        // Memory usage of String
        let stringMemory = exampleString.utf16.count * 2 // UTF-16, 2 bytes per character

        // Memory usage of Data
        let dataUTF8 = exampleString.data(using: .utf8)!
        let dataMemoryUTF8 = dataUTF8.count // 1 byte per ASCII character in UTF-8

        print("Memory used by String: \(stringMemory) bytes")
        print("Memory used by Data (UTF-8): \(dataMemoryUTF8) bytes")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
		let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
		sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
