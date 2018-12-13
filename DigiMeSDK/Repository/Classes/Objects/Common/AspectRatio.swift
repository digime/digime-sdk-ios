//
//  AspectRatio.swift
//  DigiMeRepository
//
//  Created on 26/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class AspectRatio: NSObject, Decodable {
    /// Accuracy of the match of the closest ratio to the actual ratio
    public let accuracy: Double
    
    /// Actual aspect ratio (width:height) of the resource
    public let actual: String
    
    /// Closest aspect ratio of the resource dimensions compared to set:
    /// "16:9", "4:3", "2:1", "1:1"
    public let closest: String
}
