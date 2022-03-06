//
//  Scope.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Scope used to limit service-based data retrieval to specified services and a specified time ranges
public struct Scope: Encodable {
    public let serviceGroups: [ServiceGroupScope]?
    public let timeRanges: [TimeRange]?
    
    /// Limits data retrieval to specified services or service groups and optionally to specified time range.
    /// If both service groups and time ranges are specified, then response will be limited to data matching both limits
    ///
    /// - Parameters:
    ///   - serviceGroups: Service groups (and associated services) to limit data request to
    ///   - timeRanges: Optional time range to limit data retrieval to
    public init(serviceGroups: [ServiceGroupScope], timeRanges: [TimeRange]? = nil) {
        self.serviceGroups = serviceGroups
        self.timeRanges = timeRanges
    }
    
    /// Limits data retrieval to specified time range.
    ///
    /// - Parameters:
    ///   - timeRanges: Time ranges to limit data retrieval to
    public init(timeRanges: [TimeRange]) {
        self.serviceGroups = nil
        self.timeRanges = timeRanges
    }
}
