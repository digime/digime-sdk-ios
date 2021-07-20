//
//  IntroViewController.swift
//  Genrefy
//
//  Created on 16/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, Storyboarded {
    static var storyboardName = "Onboarding"
    
    weak var coordinatingDelegate: IntroCoordinatingDelegate?
    
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var primaryButton: RoundedButton!
    
    @IBAction func primaryButtonAction(_ sender: Any) {
        coordinatingDelegate?.primaryButtonAction(sender: self)
    }
    
    var useCase: IntroViewControllerUseCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        primaryButton.backgroundColor = Theme.buttonColor
        mainTitleLabel.font = UIFont.systemFont(ofSize: Device.IS_IPHONE_5 ? 20 : 24, weight: .light)
        
        useCase.configure(mainImageView: mainImageView)
        useCase.configure(mainTitleLabel: mainTitleLabel)
        useCase.configure(primaryButton: primaryButton)
    }
}
