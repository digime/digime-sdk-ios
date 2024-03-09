//
//  Previewer.swift
//  DigiMeSDKExample
//
//  Created on 11/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let logEntry1: LogEntry
    let logEntry2: LogEntry
    let logEntry3: LogEntry
    let logEntry4: LogEntry

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: LogEntry.self, configurations: config)

        logEntry1 = LogEntry(message: "an error occured", state: .error)
        logEntry2 = LogEntry(message: "warning message", state: .warning)
        logEntry3 = LogEntry(message: "normal activity registered")
        logEntry4 = LogEntry(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")

        container.mainContext.insert(logEntry1)
        container.mainContext.insert(logEntry2)
        container.mainContext.insert(logEntry3)
        container.mainContext.insert(logEntry4)
    }
}
