//
//  UIFont+TFP.swift
//  TFP
//
//  Created on 07/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func tfpFontRegular(size: CGFloat = 18) -> UIFont {
        guard let font = UIFont(name: "SedgwickAve-Regular", size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
        
        return font
    }
}
