//
//  Duration.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Period of time (in seconds) used for attempting to retrieve new data from all service data sources.
/// In case sync is not completed within the specified duration, a partial account status will be reported in `FileList` with `SourceFetchDurationQuotaReached` error code.
/// Defaults to unlimited duration.
public struct Duration: Encodable {
    let sourceFetch: Int
    
    /// Creates an unlimited duration
    /// - Returns: An unlimited duration
    public static func unlimited() -> Duration {
        Duration(sourceFetch: 0)
    }
}

extension Duration: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.sourceFetch = max(value, 0)
    }
}
