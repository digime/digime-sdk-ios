//
//  String+Highlight.swift
//  TFP
//
//  Created by Alex Robinson  on 06/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func highlight(word: String) -> NSAttributedString {
        
        let attributedText = NSMutableAttributedString.init(string: self)
        guard let regex = try? NSRegularExpression(pattern: word, options: .caseInsensitive) else {
            return attributedText
        }
        
        regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).forEach {
            attributedText.addAttribute(.foregroundColor, value: Theme.textColor, range: $0.range)
            attributedText.addAttribute(.backgroundColor, value: Theme.highlightColor, range: $0.range)
        }
        
        return attributedText
    }
}
