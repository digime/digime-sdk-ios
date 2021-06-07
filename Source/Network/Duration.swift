//
//  Duration.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 diig.me Limited. All rights reserved.
//

import Foundation

struct Duration: Encodable {
    let sourceFetch: Int
    static func unlimited() -> Duration {
        Duration(sourceFetch: 0)
    }
}
