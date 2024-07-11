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
    @StateObject private var viewModel: SourceItemsViewModel
    @Binding var filterString: String
    @Binding var updateTrigger: Bool
    private let action: (SourceItem) -> Void
    private let rowContent: (SourceItem) -> AnyView
    private let buttonStyle: SourceSelectorButtonStyle

    init(context: ModelContext, filterString: Binding<String>, contractId: String, sampleData: Bool, servicesButtonStyle: SourceSelectorButtonStyle, updateTrigger: Binding<Bool>, @ViewBuilder rowContent: @escaping (SourceItem) -> AnyView, completion: @escaping ((SourceItem) -> Void)) {
        _filterString = filterString
        _updateTrigger = updateTrigger
        _viewModel = StateObject(wrappedValue: SourceItemsViewModel(context: context, filterString: filterString.wrappedValue, contractId: contractId, sampleData: sampleData))
        self.rowContent = rowContent
        self.action = completion
        self.buttonStyle = servicesButtonStyle
    }

    var body: some View {
        VStack {
            ForEach(viewModel.items) { item in
                Button {
                    self.action(item)
                } label: {
                    rowContent(item)
                }
                .buttonStyle(buttonStyle)
                .frame(minWidth: 0, maxWidth: .infinity)
            }

            if viewModel.canLoadMore {
                Button {
                    viewModel.loadMoreItems()
                } label: {
                    Text("Load More")
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical)
            }

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .onChange(of: filterString) { _, newValue in
            viewModel.filterString = newValue
        }
        .onChange(of: updateTrigger) { _, _ in
            // We only need to load the first batch of data if the list is empty.
            // The end user uses manual search to load filtered data.
            if viewModel.items.isEmpty {
                viewModel.resetAndReload()
            }
        }
    }
}
