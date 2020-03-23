//
//  ViewReceiptTableViewCell.swift
//  TFP
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit

class ViewReceiptTableViewCell: UITableViewCell {
    
    typealias GenericCoordinatingDelegate = AccountsViewCoordinatingDelegate
    var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bkgView.layer.cornerRadius = 10
        bkgView.layer.masksToBounds = true

        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 2.0
        shadowView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        let text = "We use digi.me private sharing to access your social posts. See and control what you have shared by opening your digi.me"
        let highlightedText = ["digi.me private sharing"]
        
        let boldFont = UIFont.systemFont(ofSize: descriptionLabel.font.pointSize, weight: .bold)
        descriptionLabel.attributedText = text.makeBold(words: highlightedText, font: boldFont)
    }
    @IBAction func viewReceipt() {
        coordinatingDelegate?.viewReceipt()
    }
    
}
