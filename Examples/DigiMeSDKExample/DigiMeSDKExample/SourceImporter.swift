//
//  SourceImporter.swift
//  DigiMeSDKExample
//
//  Created on 04/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation
import SwiftData

/// Discovery 3 data importer
class SourceImporter {
    private var modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func populateSources(contractId: String, sourceInfo: SourcesInfo) {
        autoreleasepool {
            let modelContext = ModelContext(self.modelContainer)
            modelContext.autosaveEnabled = false

            let groupedSources = Dictionary(grouping: sourceInfo.data) { $0.category.first?.id ?? 0 }

            for (groupId, sources) in groupedSources {
                sources.forEach { source in
                    let item = SourceItem(id: source.id, serviceGroupId: groupId, contractId: contractId, sampleData: source.publishedStatus == .sampledataonly, searchable: source.name, item: source)
                    modelContext.insert(item)
                }
            }

            try? modelContext.save()
        }
    }
}
