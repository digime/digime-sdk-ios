//
//  Data+Hex.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        map { String(format: "%02hhx", $0) }
            .joined()
    }
}
