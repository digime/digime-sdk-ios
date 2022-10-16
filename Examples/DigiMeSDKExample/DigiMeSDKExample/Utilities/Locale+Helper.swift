//
//  Locale+Helper.swift
//  DigiMeSDKExample
//
//  Created on 14/10/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension Locale {
    var measurementSystem: MeasurementSystemType {
        let string = (self as NSLocale).object(forKey: NSLocale.Key.measurementSystem) as! String
        
        return MeasurementSystemType(rawValue: string)!
    }
    
    enum MeasurementSystemType: String {
        case us = "U.S."
        case uk = "U.K."
        case metric = "Metric"
    }
}
