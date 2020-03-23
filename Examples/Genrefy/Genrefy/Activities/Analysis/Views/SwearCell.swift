//
//  SwearCell.swift
//  TFP
//
//  Created by Alex Robinson  on 21/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

/// NOTE: `mainView` is using backgroundColor with modified alpha instead of `alpha`
/// in order to maintain constant shadow alpha.

class SwearCell: UITableViewCell {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var viewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var swearLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    private let padding: CGFloat = 32.0
    private var previousFrameWidth: CGFloat = 0.0
    
    var amount: CGFloat = 0 {
        didSet {
            updateLayout()
            
            guard amount > 0 else {
                contentView.layoutIfNeeded()
                return
            }
            
            generateFeedback()
            animateLayoutChanges()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // only adjust the layout if the frame has changed
        // when view is initialized, the frame that's set is not necessarily correct.
        // For smaller devices it will be oversized.
        if contentView.frame.width != previousFrameWidth {
            previousFrameWidth = contentView.frame.width
            updateLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        amount = 0
        mainView.backgroundColor = UIColor(white: 1.0, alpha: amount)
        swearLabel.text = nil
        countLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewWidthConstraint.constant = 0
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOpacity = 0.35
        
        previousFrameWidth = contentView.frame.width
        
        contentView.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            mainView.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        }
        else {
            mainView.backgroundColor = UIColor(white: 1.0, alpha: amount)
        }
    }
}

// MARK:- Layout Updates
extension SwearCell {
    private func updateLayout() {
        let length = (contentView.frame.size.width - padding - 2) * amount
        viewWidthConstraint.constant = length
        mainView.backgroundColor = UIColor(white: 1.0, alpha: amount)
    }
    
    private func generateFeedback() {
        let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        lightImpactFeedbackGenerator.prepare()
        lightImpactFeedbackGenerator.impactOccurred()
    }
    
    private func animateLayoutChanges() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.contentView.layoutIfNeeded()
        }, completion: nil)
    }
}
