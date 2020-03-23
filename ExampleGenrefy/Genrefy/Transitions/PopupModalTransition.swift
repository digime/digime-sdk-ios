//
//  PopupModalTransition.swift
//  Genrefy
//
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

protocol PopupModalTransitionDelegate: class {
    
    func dismiss()
    var popupSize: CGSize? { get }
}

class PopupModalTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    weak var delegate: PopupModalTransitionDelegate?
    
    class PopupPresenter: NSObject, UIViewControllerAnimatedTransitioning {
        
        var popupModalTransition: PopupModalTransition!
        
        @objc func dismiss() {
            popupModalTransition.delegate?.dismiss()
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.7
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            
            let popupBackgroundView = PopupBackgroundView(frame: CGRect(x: 0, y: 0, width: 2000, height: 3000))
            popupBackgroundView.alpha = 0
            popupBackgroundView.tappedHandler = {
                self.dismiss()
            }
            
            container.addSubview(popupBackgroundView)
            container.isUserInteractionEnabled = true
            
            toView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(toView)
            
            let isSmall = Device.IS_IPHONE_5
            
            let width: CGFloat = popupModalTransition.delegate?.popupSize?.width ?? (isSmall ? 300 : 350)
            let height: CGFloat = popupModalTransition.delegate?.popupSize?.height ?? (isSmall ? 520 : 620)
            
            toView.heightAnchor.constraint(equalToConstant: height).isActive = true
            toView.widthAnchor.constraint(equalToConstant: width).isActive = true
            toView.centerYAnchor.constraint(equalTo: toView.superview!.centerYAnchor).isActive = true
            toView.centerXAnchor.constraint(equalTo: toView.superview!.centerXAnchor).isActive = true
            
            toView.layer.masksToBounds = true
            toView.layer.cornerRadius = 20
            
            container.layoutIfNeeded()
            let originalOriginY = toView.frame.origin.y
            toView.frame.origin.y += container.frame.height - toView.frame.minY
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                toView.frame.origin.y = originalOriginY
                popupBackgroundView.alpha = 1
            }, completion: { completed in
                transitionContext.completeTransition(completed)
            })
        }
    }
    
    class PopupDismisser: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.2
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let popupBackgroundView = container.subviews.first { $0 is PopupBackgroundView }
            
            let fromView = transitionContext.view(forKey: .from)!
            UIView.animate(withDuration: 0.2, animations: {
                fromView.frame.origin.y += container.frame.height - fromView.frame.minY
                popupBackgroundView?.alpha = 0
            }, completion: { completed in
                transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let popPresenter = PopupPresenter()
        popPresenter.popupModalTransition = self
        return popPresenter
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupDismisser()
    }
}
