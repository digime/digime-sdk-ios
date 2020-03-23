//
//  PostCell.swift
//  TFP
//
//  Created on 06/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet var serviceBar: UIView!
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var serviceIcon: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var shadowContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        serviceBar.backgroundColor = nil
        postLabel.text = nil
        postLabel.attributedText = nil
        serviceIcon.image = nil
        dateLabel.text = nil
    }
    
    func setService(_ serviceType: ServiceType) {
        serviceIcon.image = serviceType.icon()
        serviceBar.backgroundColor = serviceType.color()
    }
    
    func setDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: date)
    }
    
    func setText(_ text: String, highlightWord: String) {
        postLabel.attributedText = text.highlight(word: highlightWord)
    }
}

extension PostCell {
    func addShadow() {
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.5
        shadowContainerView.layer.shadowRadius = 2.0
        shadowContainerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
}
