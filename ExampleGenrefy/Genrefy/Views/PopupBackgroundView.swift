//
//  PopupBackgroundView.swift
//  Genrefy
//
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

class PopupBackgroundView: UIView {
    
    var tappedHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }
    
    private func initCommon() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        addGestureRecognizer(tap)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
    @objc func tapped() {
        tappedHandler?()
    }
}
