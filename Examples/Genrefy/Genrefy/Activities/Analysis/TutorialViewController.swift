//
//  TutorialViewController.swift
//  TFP
//
//  Created on 14/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class TutorialViewController: UIViewController, Coordinated {
    
    typealias GenericCoordinatingDelegate = TutorialCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    fileprivate let frameInset: CGFloat = UIScreen.main.nativeBounds.height ==  1136 ? 20 : 30 // iPhone 5/SE has smaller insets

    @IBOutlet var gifImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    var serviceType: ServiceType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.isOpaque = false
        
        guard
            let serviceType = self.serviceType,
            let image =  UIImage.gif(name: serviceType.tutorialFilename) else {
                return
        }
        
        gifImageView.animationImages = image.images
        gifImageView.animationDuration = image.duration / 3
        gifImageView.startAnimating()
        
        titleLabel.text = String(format: "Deleting %@", serviceType.tutorialServiceTitle)
    }

    @IBAction
    func closeModal(_ sender: Any) {
        self.coordinatingDelegate?.goBack()
    }
    
    func suggestedHeight() -> CGFloat {
        return suggestedWidth() * 1.8
    }
    
    func suggestedWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width - (frameInset * 2)
    }
}
