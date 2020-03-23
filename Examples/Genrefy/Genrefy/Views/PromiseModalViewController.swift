//
//  PromiseModalViewController.swift
//  DigiMe
//
//  Created on 03/09/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import UIKit

@objc protocol PromiseModalCoordinatingDelegate: CoordinatingDelegate {
    func privacyPolicyButtonAction()
}

class PromiseModalViewController: UIViewController, Coordinated {
    
    typealias GenericCoordinatingDelegate = PromiseModalCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @objc var transitionManager: PopupModalTransition? {
        didSet {
            transitioningDelegate = transitionManager
        }
    }
    
    @IBOutlet private var privacyButton: UIButton!
    
    @IBOutlet private var proceedButton: RoundedButton!
    
    @IBOutlet private var promise1Label: UILabel! {
        didSet {
            setPromise(text: "<b>Only you have the key</b><br>to see the data you import", onLabel: promise1Label)
        }
    }
    
    @IBOutlet private var promise2Label: UILabel! {
        didSet {
            setPromise(text: "<b>You decide where</b><br>your encrypted data is stored", onLabel: promise2Label)
        }
    }
    
    @IBOutlet private var promise3Label: UILabel! {
        didSet {
            setPromise(text: "<b>Only you can share</b><br>with apps and services", onLabel: promise3Label)
        }
    }
    
    @IBOutlet private var descriptionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private var promiseView1TopConstraint: NSLayoutConstraint!
    @IBOutlet private var gotItButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var promise1And2SpacingConstraint: NSLayoutConstraint!
    @IBOutlet private var promise2And3SpacingConstraint: NSLayoutConstraint!
    @IBOutlet private var promisesLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var promisesTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private var proceedButtonHeightConstraint: NSLayoutConstraint!
    
    private let isSmallScreen = Device.IS_IPHONE_5
    
    init() {
        super.init(nibName: "PromiseModalViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureConstraints()
    }
    
    @IBAction private func proceedButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func privacyButtonTapped() {
        coordinatingDelegate?.privacyPolicyButtonAction()
    }
    
    private func setPromise(text: String, onLabel label: UILabel) {
        let fontSize: CGFloat = isSmallScreen ? 15 : label.font.pointSize
        label.attributedText = text.attributed(fontSize: fontSize, plainWeight: .light)
    }
    
    private func configureConstraints() {
        if isSmallScreen {
            privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            descriptionLabelTopConstraint.constant = 8.0
            promiseView1TopConstraint.constant = 8.0
            gotItButtonBottomConstraint.constant = 10.0
            promise1And2SpacingConstraint.constant = 2.0
            promise2And3SpacingConstraint.constant = 2.0
            promisesLeadingConstraint.constant = 15.0
            promisesTrailingConstraint.constant = 15.0
            proceedButtonHeightConstraint.constant = 40.0
        }
    }
}
