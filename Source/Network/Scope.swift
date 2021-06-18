//
//  Scope.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct Scope: Encodable {
    let serviceGroups: [ServiceGroup]?
    let timeRanges: [TimeRange]?
    
    init?(serviceGroups: [ServiceGroup]? = nil, timeRanges: [TimeRange]? = nil) {
        guard serviceGroups != nil || timeRanges != nil else {
            return nil
        }
        
        self.serviceGroups = serviceGroups
        self.timeRanges = timeRanges
    }
}
