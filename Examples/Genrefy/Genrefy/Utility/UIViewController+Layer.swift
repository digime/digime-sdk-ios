//
//  UIViewController+Layer.swift
//  TFP
//
//  Created on 13/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addBackground(layer: CALayer) {
        view.backgroundColor = UIColor.clear
        layer.frame = view.frame
        view.layer.insertSublayer(layer, at: 0)
    }
    
    func addBackground(image: UIImage) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 2 * view.frame.height / 3, width: view.frame.width, height: view.frame.height / 3)
        imageView.clipsToBounds = true 
        view.insertSubview(imageView, at: 1)
    }
}
