//
//  PromotionalBanner.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

@IBDesignable class PromotionalBanner: UIView, Nibbed {
    
    var contentView: UIView?
    
    @IBOutlet weak var button: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

    @IBAction func buttonPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.digi.me") else {
            return
        }
        
        UIApplication.shared.open(url)
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
        
        let digime = "digi.me"
        
        let text = NSLocalizedString("\(digime) powers apps that want to help you get more use from your information. ", comment: "")
        let linkText = NSLocalizedString("Find out more.", comment: "")
        let normalAttributes = [.font : UIFont.systemFont(ofSize: 17, weight: .regular),
                                .foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                ] as [NSAttributedStringKey : Any]
        let attributedText = NSMutableAttributedString(string: text, attributes:normalAttributes)
        if let range = text.range(of: digime) {
            let digimeAttributes = [.font : UIFont.systemFont(ofSize: 17, weight: .bold),
                                    .foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                    ] as [NSAttributedStringKey : Any]
            attributedText.addAttributes(digimeAttributes, range: NSRange(range, in: digime))
        }
        
        let linkAttributes = [.font : UIFont.systemFont(ofSize: 17, weight: .regular),
                              .underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                              .foregroundColor : #colorLiteral(red: 0.07843137255, green: 0.5921568627, blue: 0.9019607843, alpha: 1),
                              ] as [NSAttributedStringKey : Any]
        attributedText.append(NSAttributedString(string: linkText, attributes: linkAttributes))
        button.setAttributedTitle(attributedText, for: .normal)
    }

}
