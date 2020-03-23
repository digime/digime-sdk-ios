//
//  WarningView.swift
//  TFP
//
//  Created on 14/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class WarningView: UIView, Nibbed {
    
    var contentView: UIView?
    
    @IBOutlet var warningImageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    private func xibSetup() {
        guard let view = loadViewFromNib() else
        {
            return
        }
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }
}
