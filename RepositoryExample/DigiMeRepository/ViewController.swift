//
//  ViewController.swift
//  DigiMeRepository
//
//  Created on 07/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

class ViewController: UIViewController {

    let repository = DMERepository()

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let client = repository.client
        client.authorizationDelegate = self
        
        // - INSERT your App ID here -
        client.appId = "YOUR_APP_ID"
        
        // - REPLACE 'YOUR_P12_PASSWORD' with password provided by Digi.me Ltd
        client.privateKeyHex = DMECryptoUtilities.privateKeyHex(fromP12File: "CA_RSA_PRIVATE_KEY", password: "YOUR_P12_PASSWORD")
        
        // - INSERT your Contract ID here -
        client.contractId = "gzqYsbQ1V1XROWjmqiFLcH2AF1jvcKcg"

        repository.delegate = self

        view.addSubview(startButton)
        startButton.sizeToFit()

        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.center = view.center
    }

    @objc func start() {
        print("Starting Authorization")
        repository.client.authorize()
    }
}

extension ViewController: DMERepositoryDelegate {
    func repositoryDidError(error: Error) {
        print("\(#function): \(error.localizedDescription)")
    }

    func repositoryUpdated(progress: Int) {
        print("----------------- Repo progress: \(progress)")
    }

    func repositoryDidFinishUpdate() {
        print("+++++++++++++++++ Repository is updated!")
        let accounts = repository.accounts
        
        let startDate = DateComponents(calendar: Calendar.current, year: 2018, month: 5, day: 1, hour: 0, minute: 0, second: 0).date!
        let endDate = DateComponents(calendar: Calendar.current, year: 2018, month: 5, day: 2, hour: 0, minute: 0, second: -1).date!
        
        repository.query(Transaction.self, dateRange: DateInterval(start: startDate, end: endDate), predicate: { transaction -> Bool in
            transaction.amount > 0
        }, completion: { transactions in
            guard transactions != nil else {
                return
            }
        })
        
    }
}

extension ViewController: DMEClientAuthorizationDelegate {
    func sessionCreated(_ session: CASession) {
        print("\(#function): \(session.sessionKey)")
    }

    func sessionCreateFailed(_ error: Error) {
        print("\(#function): \(error.localizedDescription)")
    }

    func authorizeSucceeded(_ session: CASession) {
        print("Authorization Success")

        repository.update()
    }

    func authorizeDenied(_ error: Error) {
        print("\(#function): \(error.localizedDescription)")
    }
    func authorizeFailed(_ error: Error) {
        print("\(#function): \(error.localizedDescription)")
    }
}
