//
//  Logger.swift
//  DigiMeSDK
//
//  Created on 30/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class Logger {
    private static var sharedLogger: Logger = {
        return Logger()
    }()
        
    var logHandler: Logging = DefaultLogger()
	var logLevelMask: LogLevelMask = [.critical, .error, .warning, .info, .mixpanel]
    
    class var logLevels: LogLevelMask {
        get {
            sharedLogger.logLevelMask
        }
        set {
            sharedLogger.logLevelMask = newValue
        }
    }
    
    class func critical(_ message: String, file: String = #file, function: String = #function, line: UInt = #line, metadata: Any? = nil) {
        sharedLogger.log(level: .critical, message: message, file: file, function: function, line: line, metadata: metadata)
    }
    
    class func error(_ message: String, file: String = #file, function: String = #function, line: UInt = #line, metadata: Any? = nil) {
        sharedLogger.log(level: .error, message: message, file: file, function: function, line: line, metadata: metadata)
    }
    
    class func warning(_ message: String, file: String = #file, function: String = #function, line: UInt = #line, metadata: Any? = nil) {
        sharedLogger.log(level: .warning, message: message, file: file, function: function, line: line, metadata: metadata)
    }
    
    class func info(_ message: String, file: String = #file, function: String = #function, line: UInt = #line, metadata: Any? = nil) {
        sharedLogger.log(level: .info, message: message, file: file, function: function, line: line, metadata: metadata)
    }
    
    class func debug(_ message: String, file: String = #file, function: String = #function, line: UInt = #line, metadata: Any? = nil) {
        sharedLogger.log(level: .debug, message: message, file: file, function: function, line: line, metadata: metadata)
    }
    
    class func mixpanel(_ message: String, file: String = #file, function: String = #function, line: UInt = #line, metadata: Any) {
        sharedLogger.log(level: .mixpanel, message: message, file: file, function: function, line: line, metadata: metadata)
    }
    
    class func setLogHandler(_ handler: @escaping LogHandler) {
        sharedLogger.logHandler = CustomLogger(handler: handler)
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: UInt, metadata: Any? = nil) {
        guard logLevelMask.contains(level) else {
            return
        }
        
        logHandler.log(level: level, message: message, file: file, function: function, line: line, metadata: metadata)
    }
}
