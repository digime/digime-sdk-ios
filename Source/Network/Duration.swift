//
//  Duration.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct Duration: Encodable {
    let sourceFetch: Int
    public static func unlimited() -> Duration {
        Duration(sourceFetch: 0)
    }
}

extension Duration: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.sourceFetch = value
    }
}
