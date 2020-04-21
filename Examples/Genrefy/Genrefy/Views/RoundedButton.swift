//
//  RoundedButton.swift
//  Genrefy
//
//  Created on 17/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton
{
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = frame.size.height / 2
    }
}
