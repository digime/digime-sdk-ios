//
//  IntroCoordinatingDelegate.swift
//  TFP
//
//  Created on 12/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

@objc protocol IntroCoordinatingDelegate: CoordinatingDelegate {
    
    func primaryButtonAction(sender: IntroViewController)
    func skipOnboarding(sender: IntroViewController)
    func secondaryButtonAction(sender: IntroViewController)
}
