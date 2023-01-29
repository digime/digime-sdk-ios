//
//  HomeViewController.swift
//  DigiMeSDKExample
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log all levels, including debug.
        DigiMe.logLevels = LogLevel.allCases
		navigationItem.largeTitleDisplayMode = .never
		navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: nil)
    }
}
