//
//  LogLevel.swift
//  DigiMeSDK
//
//  Created on 30/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// The logging levels which will be logged
public typealias LogLevelMask = [LogLevel]

/// Block signature for custom log handlers
public typealias LogHandler = ((_ level: LogLevel, _ message: String, _ file: String, _ function: String, _ line: UInt, _ metadata: Any?) -> Void)

/// Log levels which are available to be logged
public enum LogLevel: String, CaseIterable {
    case critical
    case error
    case warning
    case info
    case debug
    case mixpanel
}
