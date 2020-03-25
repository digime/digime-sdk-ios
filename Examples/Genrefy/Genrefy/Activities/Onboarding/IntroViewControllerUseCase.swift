//
//  IntroViewControllerUseCase.swift
//  TFP
//
//  Created on 12/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

protocol IntroViewControllerUseCase {
    
    func configure(mainImageView: UIImageView)
    func configure(mainTitleLabel: UILabel)
    func configure(primaryButton: UIButton)
    func configure(skipButton: UIButton)
    func configure(secondaryButton: UIButton)
}

struct HomeViewControllerUseCase: IntroViewControllerUseCase {
    func configure(mainImageView: UIImageView) {
        mainImageView.image = UIImage(named: "welcome-home")
    }
    
    func configure(mainTitleLabel: UILabel) {
        mainTitleLabel.text =  "discover your most listened to music genre on Spotify in the past 24 hours"
    }
    
    func configure(primaryButton: UIButton) {
        primaryButton.setTitle("PLUG ME IN", for: .normal)
        primaryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func configure(skipButton: UIButton) {
        skipButton.isHidden = true
    }
    
    func configure(secondaryButton: UIButton) {
        secondaryButton.isHidden = true
    }
}
