//
//  CAGradientLayer+TFP.swift
//  TFP
//
//  Created on 13/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    class func tfpLayer () -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0.0, 0.5, 1.0]
        let colors = [#colorLiteral(red: 0.009248554914, green: 0.8, blue: 0.4046242775, alpha: 1), #colorLiteral(red: 0.007843137255, green: 0.6784313725, blue: 0.3450980392, alpha: 1), #colorLiteral(red: 0.05490196078, green: 0.5098039216, blue: 0.2823529412, alpha: 1)]
        layer.colors = colors.map { $0.cgColor }
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }
    
    class func tfpRowLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0.0, 1.0]
        let colors = [#colorLiteral(red: 0.8352941176, green: 0, blue: 0.9764705882, alpha: 1), #colorLiteral(red: 1, green: 0.09019607843, blue: 0.2666666667, alpha: 1)]
        layer.colors = colors.map { $0.cgColor }
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        return layer
    }
}
