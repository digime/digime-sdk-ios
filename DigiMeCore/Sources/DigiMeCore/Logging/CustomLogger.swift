//
//  CustomLogger.swift
//  DigiMeSDK
//
//  Created on 30/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class CustomLogger: Logging {
    
    private let handlerBlock: LogHandler
    
    init(handler: @escaping LogHandler) {
        self.handlerBlock = handler
    }
    
    func log(level: LogLevel, message: String, file: String, function: String, line: UInt, metadata: Any? = nil) {
        handlerBlock(level, message, file, function, line, metadata)
    }
}
