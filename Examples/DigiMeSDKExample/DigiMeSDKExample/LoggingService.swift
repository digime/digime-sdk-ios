//
//  LoggingService.swift
//  DigiMeSDKExample
//
//  Created on 18/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

protocol LoggingServiceProtocol {
    func logMessage(_ message: LogEntry) async
    func logWarningMessage(_ message: LogEntry) async
    func logErrorMessage(_ message: LogEntry) async
    func resetLogs() async
}

@MainActor
class LoggingService: LoggingServiceProtocol {
    let modelContext: ModelContext
    let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    func logMessage(_ message: LogEntry) async {
        self.modelContext.insert(message)
    }

    func logWarningMessage(_ message: LogEntry) async {
        self.modelContext.insert(message)
    }

    func logErrorMessage(_ message: LogEntry) async {
        self.modelContext.insert(message)
    }

    func resetLogs() async {
        do {
            try modelContext.delete(model: LogEntry.self)
        }
        catch {
            print("Failed to delete all log entries.")
        }
    }
}
