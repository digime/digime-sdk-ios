//
//  String+Base64.swift
//  DigiMeSDK
//
//  Created on 10/01/2020.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

extension String {
    func base64() -> String {
        var base64 = self.replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: "-", with: "+")
        if !base64.count.isMultiple(of: 4) {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }

    func base64Url() -> String {
        let base64url = self.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        return base64url
    }
}
