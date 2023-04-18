//
//  AccountTableViewCell.swift
//  Genrefy
//
//  Created on 19/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: RoundedImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
    private var switchChangedCallback: ((String) -> Void)?
    private var uid: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
    }

    @objc private func switchChanged(_ switchView: UISwitch) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        switchChangedCallback?(uid)
    }
}

extension AccountTableViewCell: AccountCell {
    var accountIdentifier: String {
        return uid
    }
    
    func setSelectionChangedCallback(callback: @escaping ((String) -> Void)) {
        self.switchChangedCallback = callback
    }
    
    func setAccountIdentifier(_ accountIdentifier: String) {
        uid = accountIdentifier
    }
    
    func display(serviceName: String?) {
        serviceNameLabel.text = serviceName
    }
    
    func display(accountName: String?) {
        usernameLabel.text = accountName
    }
    
    func display(imageUrl: String?) {
        guard
            let imageUrl = imageUrl,
            let url = URL(string: imageUrl) else {
                logoImageView.image = nil
                return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard
                let imageData = try? Data(contentsOf: url),
                let image = UIImage(data: imageData) else {
                return
            }

            DispatchQueue.main.async {
                self.logoImageView.image = image
            }
        }
    }
    
    func display(toggleable: Bool, selected: Bool, animated: Bool) {
        switchView.isHidden = !toggleable
        switchView.setOn(selected, animated: animated)
    }
    
    func display(icon: UIImage?) {
        logoImageView.image = icon
    }
}
