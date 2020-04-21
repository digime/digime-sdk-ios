//
//  UIFont+Weight.swift
//  Genrefy
//
//  Created on 09/10/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    /// Exposes the font's weight
    @objc public var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else {
            return .regular
        }
        
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }

    private var traits: [UIFontDescriptor.TraitKey: Any] {
        return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
            ?? [:]
    }
}
