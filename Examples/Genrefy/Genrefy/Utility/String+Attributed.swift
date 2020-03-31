//
//  String+Attributed.swift
//  Genrefy
//
//  Created on 14/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /// Attempts to create an attributed string from text with HTML tags. If unable to, just returns a plain attributed string from itself
    ///
    /// - Parameters:
    ///   - fontSize: The size of the system font to attribute to whole of text
    ///   - plainWeight: The weight of the font for non-bolded sections. Defaults to `.regular`
    ///   - boldWeight: The weight of the font for bolded sections. Defaults to `.bold`
    ///   - fontColor: The default color of the text. This may be overriden by HTMl color tag
    ///   - centered: Whether a attribute to center the text is added (it seems that HTML attributed text is right-aligned by default)
    /// - Returns: An attributed string representation of itself
    public func attributed(fontSize: CGFloat, plainWeight: UIFont.Weight = .regular, boldWeight: UIFont.Weight = .bold, fontColor: UIColor = ColorCompatibility.label, centered: Bool = false) -> NSAttributedString {
        do {
            guard
                self.contains("</"),
                let data = self.data(using: .utf8) else {
                    return NSAttributedString(string: self)
            }
          
            let result = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            result.setBaseFont(fontSize: fontSize, plainWeight: plainWeight, boldWeight: boldWeight, fontColor: fontColor)
            
            if centered {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center
                result.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: result.length))
            }
            
            return result
        }
        catch {
            return NSAttributedString(string: self)
        }
    }
    
    /// Attempts to create an attributed string from HTML text. If unable to, just returns a plain attributed string from itself
    ///
    /// - Parameters:
    ///   - plainFont: The font used to determine size of the system font to attribute to whole of text and weight for plain text
    ///   - boldWeight: The weight of the font for bolded sections. Defaults to `.bold`
    ///   - fontColor: The default color of the text. This may be overriden by HTMl color tag
    ///   - centered: Whether a attribute to center the text is added (it seems that HTML attributed text is right-aligned by default)
    /// - Returns: An attributed string representation of itself
    public func attributed(plainFont: UIFont, boldWeight: UIFont.Weight = .bold, fontColor: UIColor = ColorCompatibility.label, centered: Bool = false) -> NSAttributedString {
        return attributed(fontSize: plainFont.pointSize, plainWeight: plainFont.weight, boldWeight: boldWeight, fontColor: fontColor, centered: centered)
    }
}

extension NSMutableAttributedString {
    
    /// Replaces the base font (typically Times New Roman) with a system font of given size, while preserving traits like bold and italic
    ///
    /// - Parameters:
    ///   - fontSize: The size of the system font to attribute to whole of text
    ///   - plainWeight: The weight of the font for non-bolded sections. Defaults to `.regular`
    ///   - boldWeight: The weight of the font for bolded sections. Defaults to `.bold`
    ///   - preserveFontSizes: Whether the resulting font should use the exact same size as the specified fontsize (false) or use the matching font's size (true)
    func setBaseFont(fontSize: CGFloat, plainWeight: UIFont.Weight, boldWeight: UIFont.Weight, fontColor: UIColor, preserveFontSizes: Bool = false) {
        let baseFont = UIFont.systemFont(ofSize: fontSize)
        let baseDescriptor = baseFont.fontDescriptor
        let wholeRange = NSRange(location: 0, length: length)
        beginEditing()
        enumerateAttribute(.font, in: wholeRange, options: []) { object, range, _ in
            guard let font = object as? UIFont else {
                return
            }
            
            // Instantiate a font with our base font's family, but with the current range's traits
            let traits = font.fontDescriptor.symbolicTraits
            
            guard var descriptor = baseDescriptor.withSymbolicTraits(traits) else {
                return
            }
            
            if traits.contains(.traitBold) {
                let weightTraits = [UIFontDescriptor.TraitKey.weight: boldWeight]
                descriptor = descriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: weightTraits])
            }
            else {
                let weightTraits = [UIFontDescriptor.TraitKey.weight: plainWeight]
                descriptor = descriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: weightTraits])
            }
            
            let newSize = preserveFontSizes ? descriptor.pointSize : baseDescriptor.pointSize
            let newFont = UIFont(descriptor: descriptor, size: newSize)
            self.removeAttribute(.font, range: range)
            self.addAttribute(.font, value: newFont, range: range)
        }
        enumerateAttribute(.foregroundColor, in: wholeRange, options: []) { object, range, _ in
            guard let color = object as? UIColor else {
                return
            }
            
            var white: CGFloat = 0
            var alpha: CGFloat = 0
            color.getWhite(&white, alpha: &alpha)
            // Default foreground color for attributed text is black. If so, change it.
            if white == 0 && alpha == 1 {
                self.removeAttribute(.foregroundColor, range: range)
                self.addAttribute(.foregroundColor, value: fontColor, range: range)
            }
        }
        endEditing()
    }
}

extension NSString {
    /// Attempts to create an attributed string from HTML text. If unable to, just returns a plain attributed string from itself
    ///
    /// - Parameters:
    ///   - fontSize: The size of the system font to attribute to whole of text
    ///   - plainWeight: The weight of the font for non-bolded sections. Defaults to `.regular`
    ///   - boldWeight: The weight of the font for bolded sections. Defaults to `.bold`
    ///   - fontColor: The default color of the text. This may be overriden by HTMl color tag
    ///   - centered: Whether a attribute to center the text is added (it seems that HTML attributed text is right-aligned by default)
    /// - Returns: An attributed string representation of itself
    @objc public func attributed(fontSize: CGFloat, plainWeight: UIFont.Weight = .regular, boldWeight: UIFont.Weight = .bold, fontColor: UIColor = ColorCompatibility.label, centered: Bool = false) -> NSAttributedString {
        return (self as String).attributed(fontSize: fontSize, plainWeight: plainWeight, boldWeight: boldWeight, fontColor: fontColor, centered: centered)
    }
}
