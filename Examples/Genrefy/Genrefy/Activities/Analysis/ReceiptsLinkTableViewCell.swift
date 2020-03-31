//
//  ReceiptsLinkTableViewCell.swift
//  Genrefy
//
//  Copyright © 2020 digi.me. All rights reserved.
//

import UIKit

class ReceiptsLinkTableViewCell: UITableViewCell {

    typealias GenericCoordinatingDelegate = AccountsViewCoordinatingDelegate
    var coordinatingDelegate: GenericCoordinatingDelegate?
    
    private let cache = AppStateCache()
    
    @IBOutlet weak var viewReceiptButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let date = cache.consentDate() else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d,yyyy h:mm a"
        let dateString = formatter.string(from: date)
        
        let highlightedText = "Control our access in your digi.me."
        let text = "You consented to privately share with us via digi.me on \(dateString).\n\(highlightedText)"
        let attributedString = NSMutableAttributedString(string: text)

        let boldFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let highlightedTextRange = (text as NSString).range(of: highlightedText)
        let boldTextRange = (text as NSString).range(of: dateString)
        attributedString.addAttribute(NSAttributedStringKey.font, value: boldFont, range: boldTextRange)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Theme.buttonColor, range: highlightedTextRange)

        viewReceiptButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    @IBAction func viewReceipt() {
        coordinatingDelegate?.viewReceipt()
    }
}
