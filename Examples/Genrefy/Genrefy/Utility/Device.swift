//
//  Device.swift
//  Genrefy
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
}
