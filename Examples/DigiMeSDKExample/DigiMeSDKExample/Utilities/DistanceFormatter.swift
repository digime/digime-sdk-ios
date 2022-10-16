//
//  DistanceFormatter.swift
//  DigiMeSDKExample
//
//  Created on 14/11/2017.
//  Copyright © 2017 digi.me. All rights reserved.
//

import Foundation

class DistanceFormatter: NSObject {
    class func stringFormatForDistance(km: Double) -> String {
        let formatter = LengthFormatter()
        formatter.numberFormatter.locale = Locale(identifier: "en_UK")
        formatter.numberFormatter.maximumFractionDigits = 2
        var result: String
        
        if Locale.current.measurementSystem == Locale.MeasurementSystemType.metric {
            result = formatter.string(fromValue: km, unit: .kilometer)
        }
        else {
            result = formatter.string(fromValue: km / 1.60934, unit: .mile)
        }
        
        return result
    }
}
