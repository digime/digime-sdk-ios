//
//  RoundedBorderButton.swift
//  Genrefy
//
//  Created on 10/12/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedBorderButton: RoundedButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureBorder()
    }
    
    func configureBorder() {
        layer.borderWidth = 1.0
        layer.borderColor = titleLabel?.textColor.cgColor
    }
}
