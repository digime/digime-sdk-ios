//
//  GradientView.swift
//  TFP
//
//  Created on 07/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

public class SwearGradientView: UIView {
    
    // this ensure UIKit will take care of re-sizing layer as view's constraints are updated.
    override open class var layerClass: AnyClass { return CAGradientLayer.self }
    
    private let defaultPrimaryColor: UIColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0.9764705882, alpha: 1)
    private let defaultSecondaryColor: UIColor = #colorLiteral(red: 1, green: 0.09019607843, blue: 0.2666666667, alpha: 1)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateGradient()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateGradient()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateGradient()
    }
    
    private func updateGradient() {
        let gradientLayer = layer as! CAGradientLayer
        
        gradientLayer.locations = [0.0, 1.0]
        let colors = [defaultPrimaryColor, defaultSecondaryColor]
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    public func updateGradient(primaryColor: UIColor, secondaryColor: UIColor) {
        let gradientLayer = layer as! CAGradientLayer
        
        let colors = [primaryColor, secondaryColor]
        gradientLayer.colors = colors.map { $0.cgColor }
    }
    
    public func resetGradientColor() {
        let gradientLayer = layer as! CAGradientLayer
        
        let colors = [defaultPrimaryColor, defaultSecondaryColor]
        gradientLayer.colors = colors.map { $0.cgColor }
    }
}
