//
//  UIApplication+Extension.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import UIKit

extension UIApplication {
    /// Returns whether the active window is in a landscape orientation.
    var isLandscape: Bool {
        return windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
    }
}
