//
//  IntroViewController.swift
//  Genrefy
//
//  Created on 16/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, Storyboarded, Coordinated {
    static var storyboardName = "Onboarding"
    
    typealias GenericCoordinatingDelegate = IntroCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @IBOutlet var secondaryButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var primaryButton: RoundedButton!
    @IBOutlet var secondaryButton: UIButton!
    
    @IBAction func primaryButtonAction(_ sender: Any) {
        coordinatingDelegate?.primaryButtonAction(sender: self)
    }
    
    @IBAction func secondaryButtonAction(_ sender: UIButton) {
        coordinatingDelegate?.secondaryButtonAction(sender: self)
    }
    
    var useCase: IntroViewControllerUseCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        primaryButton.backgroundColor = Theme.buttonColor
        mainTitleLabel.font = UIFont.systemFont(ofSize: Device.IS_IPHONE_5 ? 20 : 24, weight: .light)
        
        secondaryButtonHeightConstraint.constant = Device.IS_IPHONE_5 ? 0 : 20
        
        useCase.configure(mainImageView: mainImageView)
        useCase.configure(mainTitleLabel: mainTitleLabel)
        useCase.configure(primaryButton: primaryButton)
        useCase.configure(secondaryButton: secondaryButton)
    }
}
