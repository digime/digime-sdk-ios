//
//  StartOverTableViewCell.swift
//  Genrefy
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit

class StartOverTableViewCell: UITableViewCell {

    typealias GenericCoordinatingDelegate = AccountsViewCoordinatingDelegate
    var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @IBAction func reset(_ sender: RoundedButton) {
        coordinatingDelegate?.reset()
    }
}
