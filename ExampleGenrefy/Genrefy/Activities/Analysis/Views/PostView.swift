//
//  PostView.swift
//  TFP
//
//  Created on 04/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PostView: UIView, Nibbed {
    
    var contentView: UIView?
    
    @IBOutlet var serviceBar: UIView!
    @IBOutlet var serviceIcon: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    var post: TFPost?
    var service: ServiceType? {
        didSet {
            guard let service = service else {
                return
            }
            
            self.serviceIcon.image = service.icon()
            self.serviceBar.backgroundColor = service.color()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    init(withPost post: TFPost?) {
        super.init(frame: .zero)
        self.post = post
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
    
    func configure()
    {
        guard let post = post else {
            return
        }
        
        postLabel.text = post.postObject.text
        titleLabel.text = post.postObject.title
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: post.postObject.createdDate)
        
        postLabel.attributedText = post.postObject.text.highlight(word: post.matchedWord)
        titleLabel.attributedText = post.postObject.title.highlight(word: post.matchedWord)
        
        service = post.postObject.serviceType
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
        
        contentView?.clipsToBounds = false
        contentView?.layer.shadowRadius = 5
        contentView?.layer.shadowColor = UIColor.black.cgColor
        contentView?.layer.shadowOffset = .zero
        contentView?.layer.shadowOpacity = 0.5
        
        serviceIcon.image = nil
        serviceBar.backgroundColor = UIColor.white
        
        configure()
    }
}
