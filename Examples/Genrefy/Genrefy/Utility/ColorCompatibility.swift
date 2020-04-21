//
//  ColorCompatibility.swift
//  Genrefy
//
//  Created on 26/09/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import UIKit

/// Class instead of enum as we need to access these from Objective-C code
/// Can remove this class once we drop support for iOS12 and just convert all uses of this class to use UIColor instead
@objcMembers
public class ColorCompatibility: NSObject {
    
    // MARK: - System Colors
    public static var label: UIColor {
        if #available(iOS 13, *) {
            return .label
        }
        
        return .black
    }
    
    public static var secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }

        return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6)
    }
    
    public static var tertiaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .tertiaryLabel
        }
        
        return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
    }
    
    public static var quaternaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .quaternaryLabel
        }
        
        return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.18)
    }
    
    public static var systemFill: UIColor {
        if #available(iOS 13, *) {
            return .systemFill
        }
        
        return #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.5019607843, alpha: 0.2)
    }
    
    public static var secondarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemFill
        }
        
        return #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.5019607843, alpha: 0.16)
    }
    
    public static var tertiarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemFill
        }
        
        return #colorLiteral(red: 0.462745098, green: 0.462745098, blue: 0.5019607843, alpha: 0.12)
    }
    
    public static var quaternarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .quaternarySystemFill
        }
        
        return #colorLiteral(red: 0.4549019608, green: 0.4549019608, blue: 0.5019607843, alpha: 0.08)
    }
    
    public static var placeholderText: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        }
        
        return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.3)
    }
    
    public static var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        
        return .white
    }
    
    public static var secondarySystemBackground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemBackground
        }
        
        return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
    }
    
    public static var tertiarySystemBackground: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemBackground
        }
        
        return .white
    }
    
    public static var systemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemGroupedBackground
        }
        
        return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
    }
    
    public static var secondarySystemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemGroupedBackground
        }
        
        return .white
    }
    
    public static var tertiarySystemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemGroupedBackground
        }
        
        return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
    }
    
    public static var separator: UIColor {
        if #available(iOS 13, *) {
            return .separator
        }
        
        return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.29)
    }
    
    public static var opaqueSeparator: UIColor {
        if #available(iOS 13, *) {
            return .opaqueSeparator
        }
        
        return #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7843137255, alpha: 1)
    }
    
    public static var link: UIColor {
        if #available(iOS 13, *) {
            return .link
        }
        
        return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
    public static var darkText: UIColor {
        if #available(iOS 13, *) {
            return .darkText
        }
        
        return .black
    }
    
    public static var lightText: UIColor {
        if #available(iOS 13, *) {
            return .lightText
        }
        
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
    }
    
    public static var systemBlue: UIColor {
        if #available(iOS 13, *) {
            return .systemBlue
        }
        
        return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
    public static var systemGreen: UIColor {
        if #available(iOS 13, *) {
            return .systemGreen
        }
        
        return #colorLiteral(red: 0.2039215686, green: 0.7803921569, blue: 0.3490196078, alpha: 1)
    }
    
    public static var systemIndigo: UIColor {
        if #available(iOS 13, *) {
            return .systemIndigo
        }
        
        return #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8392156863, alpha: 1)
    }
    
    public static var systemOrange: UIColor {
        if #available(iOS 13, *) {
            return .systemOrange
        }
        
        return #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
    }
    
    public static var systemPink: UIColor {
        if #available(iOS 13, *) {
            return .systemPink
        }
        
        return #colorLiteral(red: 1, green: 0.1764705882, blue: 0.3333333333, alpha: 1)
    }
    
    public static var systemPurple: UIColor {
        if #available(iOS 13, *) {
            return .systemPurple
        }
        
        return #colorLiteral(red: 0.6862745098, green: 0.3215686275, blue: 0.8705882353, alpha: 1)
    }
    
    public static var systemRed: UIColor {
        if #available(iOS 13, *) {
            return .systemRed
        }
        
        return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
    }
    
    public static var systemTeal: UIColor {
        if #available(iOS 13, *) {
            return .systemTeal
        }
        
        return #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)
    }
    
    public static var systemYellow: UIColor {
        if #available(iOS 13, *) {
            return .systemYellow
        }
        
        return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
    }
    
    public static var systemGray: UIColor {
        if #available(iOS 13, *) {
            return .systemGray
        }
        
        return #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
    }
    
    public static var systemGray2: UIColor {
        if #available(iOS 13, *) {
            return .systemGray2
        }
        
        return #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6980392157, alpha: 1)
    }
    
    public static var systemGray3: UIColor {
        if #available(iOS 13, *) {
            return .systemGray3
        }
        
        return #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.8, alpha: 1)
    }
    
    public static var systemGray4: UIColor {
        if #available(iOS 13, *) {
            return .systemGray4
        }
        
        return #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8392156863, alpha: 1)
    }
    
    public static var systemGray5: UIColor {
        if #available(iOS 13, *) {
            return .systemGray5
        }
        
        return #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 1)
    }
    
    public static var systemGray6: UIColor {
        if #available(iOS 13, *) {
            return .systemGray6
        }
        
        return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
    }
}
