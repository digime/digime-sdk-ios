//
//  ConsentRequestViewController.swift
//  Genrefy
//
//  Created on 16/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class ConsentRequestViewController: UIViewController, Storyboarded, Coordinated {
    static var storyboardName = "Onboarding"
    
    @IBOutlet var launchConsentButton: RoundedButton!
    
    typealias GenericCoordinatingDelegate = ConsentRequestCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @IBOutlet weak var consentRequestButton: RoundedButton!
    
    @IBOutlet var whyDigimeLabel: UILabel!
    private let highlightedText = "WHY? digi.me"
    
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
        
        let text = whyDigimeLabel.text
        let boldFont = UIFont.systemFont(ofSize: whyDigimeLabel.font.pointSize, weight: .bold)
        whyDigimeLabel.attributedText = text?.makeBold(words: [highlightedText], font: boldFont)
        launchConsentButton.setTitle("Open now", for: .normal)
    }
}
