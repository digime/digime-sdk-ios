//
//  DigiMeSDKExampleApp.swift
//  DigiMeSDKExample
//
//  Created on 26/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct DigiMeSDKExampleApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for:
                                           LogEntry.self,
                                           SelfMeasurement.self,
                                           SelfMeasurementReceipt.self,
                                           SelfMeasurementComponent.self,
                                           HealthDataExportItem.self,
                                           HealthDataExportFile.self,
                                           HealthDataExportSection.self,
                                           SourceItem.self
            )
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }

	var body: some Scene {
		WindowGroup {
            let loggingService = LoggingService(modelContainer: container)
            let servicesViewModel = ServicesViewModel(loggingService: loggingService, modelContainer: container)
            let scopeViewModel = ScopeViewModel()
            HomeView(modelContainer: container, loggingService: loggingService, servicesViewModel: servicesViewModel, scopeViewModel: scopeViewModel)
		}
        .modelContainer(container)
	}
}
