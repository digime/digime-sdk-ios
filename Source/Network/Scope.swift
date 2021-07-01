//
//  Scope.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct Scope: Encodable {
    let serviceGroups: [ServiceGroup]?
    let timeRanges: [TimeRange]?
    
    public init(serviceGroups: [ServiceGroup], timeRanges: [TimeRange]? = nil) {
        self.serviceGroups = serviceGroups
        self.timeRanges = timeRanges
    }
    
    public init(timeRanges: [TimeRange]) {
        self.serviceGroups = nil
        self.timeRanges = timeRanges
    }
}
