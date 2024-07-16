//
//  DigimeMainViewController.swift
//  DigiMePluginExample
//
//  Created on 11/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

@objc public class DigimeMainViewController: UIViewController {
    @State private var navigationPath = NavigationPath()
    let container: ModelContainer

    public init() {
        do {
            container = try ModelContainer(for:
                                            HealthDataExportItem.self,
                                            HealthDataExportFile.self,
                                            HealthDataExportSection.self
            )
        }
        catch {
            fatalError(error.localizedDescription)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // let rootView = HomeView(modelContainer: container).modelContainer(container)

        let rootView = HealthDataPermissionView(modelContainer: container)
        let hostingController = UIHostingController(rootView: rootView)
        let navigationController = UINavigationController(rootViewController: hostingController)

        hostingController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "close".localized(),
            style: .plain,
            target: self,
            action: #selector(dismissButtonTapped)
        )
        addChild(navigationController)
        navigationController.view.frame = view.bounds
        view.addSubview(navigationController.view)
        navigationController.didMove(toParent: self)

        // addChild(hostingController)
        // hostingController.view.frame = view.bounds
        // view.addSubview(hostingController.view)
        // hostingController.didMove(toParent: self)
    }

    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
