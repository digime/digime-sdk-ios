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
        mainTitleLabel.text =  "Clean up your social media presence with Post Cleaner, because you only have one chance to make a first impression"
    }
    
    func configure(primaryButton: UIButton) {
        primaryButton.setTitle("Tell me more", for: .normal)
        primaryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func configure(skipButton: UIButton) {
        skipButton.isHidden = false
    }
    
    func configure(secondaryButton: UIButton) {
        secondaryButton.isHidden = true
    }
}

struct IntroductionViewControllerUseCase: IntroViewControllerUseCase {
    func configure(mainImageView: UIImageView) {
        mainImageView.image = UIImage(named: "welcome-intro")
    }
    
    func configure(mainTitleLabel: UILabel) {
        mainTitleLabel.text = "Post Cleaner imports and privately scans your enitre social media history to find posts that may be offensive"
    }

    func configure(primaryButton: UIButton) {
        primaryButton.setTitle("How does it work?", for: .normal)
        primaryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func configure(skipButton: UIButton) {
        skipButton.isHidden = false
    }
    
    func configure(secondaryButton: UIButton) {
        secondaryButton.isHidden = true
    }
}

struct ProcessViewControllerUseCase: IntroViewControllerUseCase {
    func configure(mainImageView: UIImageView) {
        mainImageView.image = UIImage(named: "welcome-process")
    }
    
    func configure(mainTitleLabel: UILabel) {
        mainTitleLabel.text = "Our living library of over 3,000 words and phrases is used to identify potentially offensive posts"
    }

    func configure(primaryButton: UIButton) {
        primaryButton.setTitle("So, what do I do?", for: .normal)
        primaryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func configure(skipButton: UIButton) {
        skipButton.isHidden = false
    }
    
    func configure(secondaryButton: UIButton) {
        secondaryButton.isHidden = true
    }
}

struct HowtoViewControllerUseCase: IntroViewControllerUseCase {
    func configure(mainImageView: UIImageView) {
        mainImageView.image = UIImage(named: "welcome-howto")
    }
    
    func configure(mainTitleLabel: UILabel) {
        mainTitleLabel.text = "It’s then up to you to review the identified posts to decide whether they should be kept, edited or deleted"
    }

    func configure(primaryButton: UIButton) {
        primaryButton.setTitle("OK, let’s do this", for: .normal)
        primaryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }

    func configure(skipButton: UIButton) {
        skipButton.isHidden = false
    }
    
    func configure(secondaryButton: UIButton) {
        secondaryButton.isHidden = true
    }
}

struct CALaunchViewControllerUseCase: IntroViewControllerUseCase {
    func configure(mainImageView: UIImageView) {
        mainImageView.image = UIImage(named: "welcome-calaunch")
    }
    
    func configure(mainTitleLabel: UILabel) {
        let text = "We use digi.me private sharing to safely analyse your social media posts"
        let highlightedText = ["digi.me private sharing"]
        
        let boldFont = UIFont.systemFont(ofSize: mainTitleLabel.font.pointSize, weight: .bold)
        mainTitleLabel.attributedText = text.makeBold(words: highlightedText, font: boldFont)
    }
    
    func configure(primaryButton: UIButton) {
        primaryButton.setTitle("Connect my sources", for: .normal)
        primaryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func configure(skipButton: UIButton) {
        skipButton.isHidden = true
    }
    
    func configure(secondaryButton: UIButton) {
        secondaryButton.setTitle("What is digi.me?", for: .normal)
    }
}
