//
//  SourceItemsListView.swift
//  DigiMeSDKExample
//
//  Created on 05/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

struct SourceItemsListView: View {
    @Query private var items: [SourceItem]

    private let action: (SourceItem) -> Void
    private let rowContent: (SourceItem) -> AnyView
    private let buttonStyle: SourceSelectorButtonStyle

    init(filterString: String, contractId: String, groupId: Int, sampleData: Bool, servicesButtonStyle: SourceSelectorButtonStyle, @ViewBuilder rowContent: @escaping (SourceItem) -> AnyView, completion: @escaping ((SourceItem) -> Void)) {
        self.rowContent = rowContent
        self.action = completion
        self.buttonStyle = servicesButtonStyle

        let predicate = #Predicate<SourceItem> { item in
            (filterString.isEmpty || item.searchable.localizedStandardContains(filterString))
            && (sampleData || (!sampleData && item.sampleData == sampleData))
            && item.serviceGroupId == groupId
            && item.contractId == contractId
        }

        var descriptor = FetchDescriptor<SourceItem>(predicate: predicate, sortBy: [
            SortDescriptor(\SourceItem.searchable, order: .forward)
        ])

        if !filterString.isEmpty {
            descriptor.fetchLimit = 100
        }

        _items = Query(descriptor)
    }

    var body: some View {
        LazyVStack {
            ForEach(items) { item in
                Button {
                    self.action(item)
                } label: {
                    rowContent(item)
                }
                .buttonStyle(buttonStyle)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    let loggingService = LoggingService(modelContainer: previewer!.container)
    let servicesViewModel = ServicesViewModel(loggingService: loggingService, modelContainer: previewer!.container)
    let style = SourceSelectorButtonStyle(backgroundColor: Color("pickerBackgroundColor"), foregroundColor: .primary, padding: 15)
    return SourceItemsListView(filterString: "", contractId: "testContractId", groupId: 2, sampleData: false, servicesButtonStyle: style) { item in
        AnyView(Text(item.searchable))
    } completion: { item in
        print("selected item id: \(item.id)")
    }
    .environmentObject(servicesViewModel)
    .modelContainer(previewer!.container)
    .environment(\.colorScheme, .dark)
}
