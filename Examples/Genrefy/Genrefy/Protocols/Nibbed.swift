//
//  Nibbed.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

protocol Nibbed {
    func loadViewFromNib() -> UIView?
}

extension Nibbed where Self: UIView {
    func loadViewFromNib() -> UIView? {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(type(of: self))
        
        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: className, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
