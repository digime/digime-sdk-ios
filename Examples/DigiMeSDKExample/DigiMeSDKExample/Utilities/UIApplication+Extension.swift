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
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
			return false
		}
		
		return windowScene.interfaceOrientation.isLandscape
    }
}
