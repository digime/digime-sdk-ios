//
//  Extensions+Double.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public extension Double {
    var asDate: Date {
        return Date(timeIntervalSince1970: self)
    }
	
    var secondsSince1970: Double {
        return (self / 1000)
    }
}
