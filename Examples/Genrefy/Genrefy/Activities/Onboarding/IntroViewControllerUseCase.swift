//
//  IntroViewControllerUseCase.swift
//  Genrefy
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
        primaryButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
