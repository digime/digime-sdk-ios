//
//  WelcomeViewController.swift
//  DigiMeSDKExampleSwift
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "DigiMeSDKExample"
    }

    @IBAction func showCAExample() {
        performSegue(withIdentifier: "ShowCAExample", sender: self)
    }
    
    @IBAction func showPostboxExample() {
        performSegue(withIdentifier: "ShowPostboxExample", sender: self)
    }
}
