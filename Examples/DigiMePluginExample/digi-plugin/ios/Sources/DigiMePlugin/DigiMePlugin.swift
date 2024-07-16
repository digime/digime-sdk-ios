//
//  DigiMePlugin.swift
//  DigiMePluginExample
//
//  Created on 11/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import Capacitor
import UIKit

@objc(DigiMePlugin)
public class DigiMePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "DigiMePlugin"
    public let jsName = "DigiPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "fetchHealthData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "dismissView", returnType: CAPPluginReturnPromise)
    ]

    private weak var presentedViewController: UIViewController?

    @objc func fetchHealthData(_ call: CAPPluginCall) {
        guard let appId = call.getString("appId"),
              let identifier = call.getString("identifier"),
              let privateKey = call.getString("privateKey"),
              let baseURL = call.getString("baseURL"),
              let storageBaseURL = call.getString("storageBaseURL"),
              let cloudId = call.getString("cloudId") else {

            call.reject("Missing required parameters")
            return
        }

        print("App ID: \(appId)")
        print("Identifier: \(identifier)")
        print("Private Key: \(privateKey.prefix(20))...")
        print("Base URL: \(baseURL)")
        print("Storage Base URL: \(storageBaseURL)")
        print("Cloud ID: \(cloudId)")

        print("Preferred Locale Language: \(String(describing: Locale.preferredLanguages.first))")
        print("Preferred Bundle Language: \(Bundle.main.preferredLocalizations.first ?? "Unknown")")

        let contract = DigimeContract(name: "",
                                       appId: appId,
                                       identifier: identifier,
                                       privateKey: privateKey,
                                       baseURL: baseURL,
                                       storageBaseURL: storageBaseURL)

        UserPreferences.shared().setStorageId(identifier: cloudId, for: identifier)
        UserPreferences.shared().activeContract = contract

        DispatchQueue.main.async {
            let vc = DigimeMainViewController()
            vc.modalPresentationStyle = .fullScreen
            if let rootViewController = self.bridge?.viewController {
                rootViewController.present(vc, animated: true) {
                    self.presentedViewController = vc
                    call.resolve([
                        "value": "Digi.me Apple Health flow successfully initiated."
                    ])
                }
            } 
            else {
                call.reject("Unable to get root view controller")
            }
        }
    }

    @objc func dismissView(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true) {
                call.resolve()
            }
        }
    }
}
