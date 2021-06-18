//
//  Limits.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct Limits: Encodable {
    let duration: Duration
    
    init(duration: Duration) {
        self.duration = duration
    }
    
    init(sourceFetchDuration: Int) {
        duration = Duration(sourceFetch: sourceFetchDuration)
    }
}
