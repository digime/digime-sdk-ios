//
//  GenreCell.swift
//  Genrefy
//
//  Created on 21/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class GenreCell: UITableViewCell {
    
    @IBOutlet var percentView: UIView!
    @IBOutlet var percentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var swearLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    private let padding: CGFloat = 24
    private var previousFrameWidth: CGFloat = 0.0
    var barColor: UIColor = .clear {
        didSet {
            percentView.backgroundColor = barColor
        }
    }
    
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
        percentView.backgroundColor = nil
        swearLabel.text = nil
        countLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        percentViewWidthConstraint.constant = 0
        previousFrameWidth = contentView.frame.width
        
        contentView.layoutIfNeeded()
    }
}

// MARK:- Layout Updates
extension GenreCell {
    private func updateLayout() {
        let length = (contentView.frame.size.width - padding) * amount
        percentViewWidthConstraint.constant = length
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
