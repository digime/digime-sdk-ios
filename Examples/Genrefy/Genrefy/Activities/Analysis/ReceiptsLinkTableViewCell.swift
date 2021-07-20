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
    
    @IBOutlet weak var receiptLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let date = cache.consentDate() else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d,yyyy h:mm a"
        let dateString = formatter.string(from: date)
        
        let text = "You consented to privately share with us via digi.me on \(dateString)."
        let attributedString = NSMutableAttributedString(string: text)

        let boldFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let boldTextRange = (text as NSString).range(of: dateString)
        attributedString.addAttribute(.font, value: boldFont, range: boldTextRange)

        receiptLabel.attributedText = attributedString
    }
}
