//
//  String+Helper.swift
//  DigiMeSDK
//
//  Created on 19/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension String {
    public static func random(length: Int) -> String {
        var result = String()
        for _ in 1...length {
            result += "\(Int.random(in: 1...9))"
        }
        
        return result
    }
}
