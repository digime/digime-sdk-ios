//
//  AccountCell.swift
//  Genrefy
//
//  Created on 19/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

protocol AccountCell {
    
    var accountIdentifier: String { get }
    func setSelectionChangedCallback(callback: @escaping ((String) -> Void))
    func setAccountIdentifier(_ accountIdentifier: String)
    
    func display(serviceName: String?)
    func display(accountName: String?)
    func display(imageUrl: String?)
    func display(toggleable: Bool, selected: Bool, animated: Bool)
    func display(icon: UIImage?)
}
