//
//  SourceItemsViewModel.swift
//  DigiMeSDKExample
//
//  Created on 09/07/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

class SourceItemsViewModel: ObservableObject {
    @Published private(set) var items: [SourceItem] = []

    @Published var updateTrigger = false
    @Published var isLoading = false
    @Published var canLoadMore = true
    @Published var filterString: String {
        didSet {
            resetAndReload()
        }
    }

    private var currentPage = 0
    private let pageSize = 20
    private var descriptor: FetchDescriptor<SourceItem>

    private let context: ModelContext
    private let contractId: String
    private let sampleData: Bool

    init(context: ModelContext, filterString: String, contractId: String, sampleData: Bool) {
        self.context = context
        self.filterString = filterString
        self.contractId = contractId
        self.sampleData = sampleData

        self.descriptor = Self.createDescriptor(filterString: filterString, contractId: contractId, sampleData: sampleData)

        loadMoreItems()
    }

    private static func createDescriptor(filterString: String, contractId: String, sampleData: Bool) -> FetchDescriptor<SourceItem> {
        let predicate = #Predicate<SourceItem> { item in
            (filterString.isEmpty || item.searchable.localizedStandardContains(filterString))
            && (sampleData || (!sampleData && item.sampleData == sampleData))
            && item.contractId == contractId
        }

        let descriptor = FetchDescriptor<SourceItem>(predicate: predicate, sortBy: [
            SortDescriptor(\SourceItem.searchable, order: .forward)
        ])

        return descriptor
    }

    func loadMoreItems() {
        guard canLoadMore && !isLoading else {
            return
        }

        isLoading = true

        descriptor.fetchOffset = currentPage * pageSize
        descriptor.fetchLimit = pageSize

        do {
            let newItems = try context.fetch(descriptor)
            items.append(contentsOf: newItems)
            currentPage += 1
            canLoadMore = newItems.count == pageSize
            updateTrigger.toggle()
        }
        catch {
            print("Error fetching items: \(error)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isLoading = false
        }
    }

    func resetAndReload() {
        items = []
        currentPage = 0
        canLoadMore = true
        isLoading = false
        descriptor = Self.createDescriptor(filterString: filterString, contractId: contractId, sampleData: sampleData)
        loadMoreItems()
        updateTrigger.toggle()
    }
}

