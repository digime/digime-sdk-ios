//
//  String+Bold.swift
//  DigiMe
//
//  Created on 08/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func makeBold(words: [String], font: UIFont) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString.init(string: self)
        
        for word in words {
            guard let regex = try? NSRegularExpression(pattern: word, options: [.ignoreMetacharacters]) else {
                continue
            }
            
            regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).forEach {
                attributedText.addAttribute(.font, value: font, range: $0.range)
            }
        }
        
        return attributedText
    }
}
