//
//  Data+Base64.swift
//  DigiMeSDK
//
//  Created on 10/01/2020.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

extension Data {
    init?(base64URLEncoded string: String) {
        self.init(base64Encoded: string.base64())
    }

    func base64URLEncodedString() -> String {
        return self.base64EncodedString().base64Url()
    }
}
