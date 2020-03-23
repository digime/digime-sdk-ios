//
//  NoAppConsentRequestViewController.swift
//  TFP
//
//  Created by Alex Yushchenko on 10/12/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class NoAppConsentRequestViewController: UIViewController, Storyboarded, Coordinated {
    static var storyboardName = "Onboarding"
    
    @IBOutlet var launchConsentButton: RoundedButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    typealias GenericCoordinatingDelegate = ConsentRequestCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    var isDigiMeInstalled = false {
        didSet {
            configureConsentButtonText()
        }
    }
    
    @IBOutlet weak var consentRequestButton: RoundedButton!
    
    private let whyText = "Why?"
    private let digiMeText = "digi.me"
    
    @IBAction func launchConsentRequest(_ sender: Any) {
        coordinatingDelegate?.startConsentRequest()
    }
    
    @IBAction func goBack(_ sender: Any) {
        coordinatingDelegate?.goBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        consentRequestButton.backgroundColor = Theme.buttonColor
        
        addBackground(layer: CAGradientLayer.tfpLayer())
        
        addBackground(image: #imageLiteral(resourceName: "waves"))

        highlightText()
        configureConsentButtonText()
    }
    
    private func configureConsentButtonText() {
        if isDigiMeInstalled {
            launchConsentButton.setTitle("Open now", for: .normal)
        }
        else {
            launchConsentButton.setTitle("Install digi.me now", for: .normal)
        }
    }
    
    private func highlightText() {
        var text = descriptionLabel.text
        var boldFont = UIFont.systemFont(ofSize: descriptionLabel.font.pointSize, weight: .bold)
        descriptionLabel.attributedText = text?.makeBold(words: [whyText, digiMeText], font: boldFont)
        
        text = subtitleLabel.text
        boldFont = UIFont.systemFont(ofSize: subtitleLabel.font.pointSize, weight: .bold)
        subtitleLabel.attributedText = text?.makeBold(words: [whyText, digiMeText], font: boldFont)
    }
    
    @IBAction func enterTwitterName(_ sender: UIButton) {
        coordinatingDelegate?.startTwitterDemo()
    }
}
