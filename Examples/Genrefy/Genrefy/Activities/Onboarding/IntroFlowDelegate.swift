//
//  IntroFlowDelegate.swift
//  TFP
//
//  Created on 12/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

@objc protocol IntroFlowDelegate: CoordinatingDelegate {
    var onboardingViewControllers: [IntroViewController] { get }
    func viewController(after vc: IntroViewController) -> IntroViewController?
    func viewController(before vc: IntroViewController) -> IntroViewController?
    func updatePageControl(for pageViewController: IntroPageViewController)
}
