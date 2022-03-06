//
//  Limits.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct Limits: Encodable {
    public let duration: Duration
    
    /// Initializes a Limits object with a duration
    ///
    /// The duration can either be specified as a Duration object or an Int:
    /// ````
    /// let limits = Limits(duration: 9)
    /// let limits = Limits(duration: Duration.unlimited())
    /// ````
    ///
    /// - Parameter duration: The duration, in seconds, allowed for retrieving new content from all sources
    ///
    public init(duration: Duration) {
        self.duration = duration
    }
}
