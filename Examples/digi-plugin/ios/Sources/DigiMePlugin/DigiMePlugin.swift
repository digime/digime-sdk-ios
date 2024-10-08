//
//  DigiMePlugin.swift
//  DigiMePluginExample
//
//  Created on 11/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import Foundation
import Capacitor
import UIKit
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
@objc(DigiMePlugin)
public class DigiMePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "DigiMePlugin"
    public let jsName = "DigiPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "fetchHealthData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "dismissView", returnType: CAPPluginReturnPromise)
    ]

    private var modelContainer: ModelContainer?
    private weak var presentedViewController: UIViewController?
    private var currentCall: CAPPluginCall?
    private var completion: ((Result<[String], Error>) -> Void)?

    @objc func fetchHealthData(_ call: CAPPluginCall) {
        guard let cloudId = call.getString("cloudId") else {
            call.resolve([
                "success": false,
                "error": "Missing required parameters"
            ])
            return
        }

        self.currentCall = call

        // Initialize ModelContainer
        do {
            modelContainer = try ModelContainer(for: HealthDataExportItem.self, HealthDataExportFile.self, HealthDataExportSection.self)
        } 
        catch {
            call.resolve([
                "success": false,
                "error": "Failed to initialize ModelContainer: \(error.localizedDescription)"
            ])
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let modelContainer = self.modelContainer else {
                call.resolve([
                    "success": false,
                    "error": "ModelContainer not initialized"
                ])
                return
            }

            self.completion = { result in
                switch result {
                case .success(let urls):
                    self.currentCall?.resolve([
                        "success": true,
                        "values": urls
                    ])
                case .failure(let error):
                    self.currentCall?.resolve([
                        "success": false,
                        "error": error.localizedDescription
                    ])
                }

                self.dismissView(nil)
            }

            let viewModel = HealthDataViewModel(modelContainer: modelContainer, cloudId: cloudId, onComplete: self.completion)
            let rootView = ReportDateManagerView(viewModel: viewModel)
            let hostingController = UIHostingController(rootView: rootView)
            hostingController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "close".localized(),
                style: .plain,
                target: self,
                action: #selector(dismissView(_:))
            )

            let navigationController = UINavigationController(rootViewController: hostingController)

            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.tintColor = .systemBlue

            navigationController.modalPresentationStyle = .fullScreen

            if let rootViewController = self.bridge?.viewController {
                rootViewController.present(navigationController, animated: true) {
                    self.presentedViewController = navigationController
                }
            }
            else {
                call.resolve([
                    "success": false,
                    "error": "Unable to get root view controller"
                ])
            }
        }
    }

    // Present view from the app delegate directly. Debugging purpose only
    public func presentHealthDataView(cloudId: String, from viewController: UIViewController? = nil) {
        // Initialize ModelContainer
        do {
            modelContainer = try ModelContainer(for: HealthDataExportItem.self, HealthDataExportFile.self, HealthDataExportSection.self)
        }
        catch {
            print("Failed to initialize ModelContainer: \(error.localizedDescription)")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let modelContainer = self.modelContainer else {
                print("ModelContainer not initialized")
                return
            }

            self.completion = { result in
                switch result {
                case .success(let urls):
                    print("Success: \(urls)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }

                self.dismissView(nil)
            }

            let viewModel = HealthDataViewModel(modelContainer: modelContainer, cloudId: cloudId, onComplete: self.completion)
            let rootView = ReportDateManagerView(viewModel: viewModel)
            let hostingController = UIHostingController(rootView: rootView)
            hostingController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "close".localized(),
                style: .plain,
                target: self,
                action: #selector(dismissView(_:))
            )

            let navigationController = UINavigationController(rootViewController: hostingController)

            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.tintColor = .systemBlue

            navigationController.modalPresentationStyle = .fullScreen

            if let rootViewController = viewController ?? self.bridge?.viewController {
                rootViewController.present(navigationController, animated: true) {
                    self.presentedViewController = navigationController
                }
            }
            else {
                print("Unable to get root view controller")
            }
        }
    }

    @objc func dismissView(_ sender: Any?) {
        DispatchQueue.main.async { [weak self] in
            self?.presentedViewController?.dismiss(animated: true) {
                if let call = sender as? CAPPluginCall {
                    call.resolve()
                }
            }
        }
    }

    @objc func dismissViewFromPlugin(_ call: CAPPluginCall) {
        dismissView(call)
    }
}
#endif
