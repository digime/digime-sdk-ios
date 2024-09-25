//
//  SourcePickerView.swift
//  DigiMeSDKExample
//
//  Created on 02/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import Foundation
import SwiftData
import SwiftUI

struct SourcePickerView: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var showView: Bool
    @Binding var selectSourceCompletion: ((Source, String?) -> Void)?

    @ObservedObject var viewModel: ServicesViewModel
    @ObservedObject var scopeViewModel: ScopeViewModel

    @State var viewState: ConnectSourceViewState
    @State private var showSampleDataSetActionSheet = false
    @State private var showSampleDataErrorActionSheet = false
    @State private var proceedSampleDataset = false
    @State private var pushNextView = false
    @State private var proceedButtonIsPressed = false
    @State private var searchText: String = ""
    @State private var timeRangeTemplates: [TimeRangeTemplate] = TestTimeRangeTemplates.data
    @State private var objectTypes: [ServiceObjectType] = []

    var allowScoping: Bool

    private var servicesButtonStyle: SourceSelectorButtonStyle {
        if viewState == .sampleData {
            return SourceSelectorButtonStyle(backgroundColor: Color("pickerBackgroundColor"), foregroundColor: viewModel.isLoadingData ? .gray : .primary, padding: 15)
        }
        else {
            return SourceSelectorButtonStyle(backgroundColor: Color("pickerItemColor"), foregroundColor: viewModel.isLoadingData ? .gray : .primary, padding: 15)
        }
    }

    private var navigationButtonStyle: SourceSelectorButtonStyle {
        return SourceSelectorButtonStyle(backgroundColor: Color(.systemGroupedBackground), foregroundColor: viewModel.isLoadingData ? .gray : .primary, padding: 10, strokeColor: .primary)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewState == .sources {
                            sourcesHeaderView
                        }
                        else if viewState == .sampleData {
                            sampleDataHeaderView
                        }
                    }
                    .padding(.bottom, 10)

                    searchBar
                    content
                }
                .background(.clear)
                .scrollIndicators(.hidden)
                .padding(.horizontal, 20)
                .navigationBarItems(leading: cancelButton)
                .toolbar {
                    if viewModel.isLoadingData {
                        ActivityIndicator()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                    else {
                        addServiceButton
                    }
                }

                if allowScoping && scopeViewModel.selectedSource != nil {
                    VStack(spacing: 20) {
                        scopingToggle

                        if scopeViewModel.isScopeModificationAllowed {
                            scopingPreview
                        }

                        buttonProceed
                    }
                    .padding()
                    .background(viewState == .sampleData ? Color.clear : Color(.systemGroupedBackground))
                }
            }
            .background(viewState == .sampleData ? Color.yellow.opacity(0.1) : Color(.systemBackground))
        }
        .onAppear {
            viewModel.onShowSampleDataSelectorChanged = { shouldShow in
                self.showSampleDataSetActionSheet = shouldShow
            }

            viewModel.onShowSampleDataErrorChanged = { shouldShow in
                self.showSampleDataErrorActionSheet = shouldShow
            }

            viewModel.onProceedSampleDatasetChanged = { proceed in
                self.proceedSampleDataset = proceed
            }
        }
        .customActionPickerView(isPresented: $showSampleDataSetActionSheet,
                                title: "Sample Datasets",
                                message: "Choose one to proceed",
                                buttons: customActionSheetPickerButtons())
        .sheet(isPresented: $scopeViewModel.shouldDisplayModal) {
            ScopeAddView(viewModel: scopeViewModel)
        }
        .onChange(of: scopeViewModel.selectedSource) { _, newValue in
            guard
                let source = newValue,
                let groupId = source.serviceGroupIds.first,
                let data = TestServiceObjectTypesByGroups.data.first(where: { $0.id == groupId })?.items else {
                return
            }

            scopeViewModel.objectTypes = data
            scopeViewModel.selectedObjectTypes = Set(data.map { $0.id })
        }
        .onChange(of: scopeViewModel.selectedObjectTypes) { _, newValue in
            objectTypes = scopeViewModel.objectTypes.filter { newValue.contains($0.id) }
        }
        .onChange(of: proceedSampleDataset) { _, _ in
            finish(sampleDataset: viewModel.sampleDatasets?.first?.key)
        }
        .alert("Sample Datasets", isPresented: $showSampleDataErrorActionSheet, actions: {
            Button("Use your personal data") {
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Button("Ask us for a sample set", role: .destructive) {
                DispatchQueue.main.async {
                    if let url = URL(string: "mailto:support@digi.me?subject=I'd like a sample dataset for \(scopeViewModel.selectedSource?.name ?? "a service")") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }, message: {
            Text("No sample datasets available at this time")
        })
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .disabled(viewModel.isLoadingData)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search in \(counter) items", text: $searchText)
                .padding(3)

            if !searchText.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color(.systemGray3))
                    .onTapGesture {
                        self.searchText = ""
                    }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(viewState == .sampleData ? Color("pickerBackgroundColor") : Color("pickerItemColor"))
        }
    }

    private var counter: Int {
        viewState == .sampleData ? viewModel.totalNumberOfSampleDataItems : viewModel.totalNumberOfItems
    }

    private var content: some View {
        SourceItemsListView(
            context: ModelContext(viewModel.modelContainer),
            filterString: $searchText,
            contractId: viewModel.activeContract.identifier,
            sampleData: viewState == .sampleData,
            servicesButtonStyle: servicesButtonStyle,
            updateTrigger: $viewModel.sourceItemsUpdateTrigger,
            rowContent: { item in
                AnyView(self.makeSourceRow(source: item))
            }, completion: { sourceItem in
                guard
                    !viewModel.isLoadingData,
                    let source = sourceItem.items.first else {
                    return
                }

                scopeViewModel.selectedSource = source
                viewModel.sampleDatasets = nil

                if !allowScoping {
                    if viewState == .sampleData {
                        viewModel.fetchDemoDataSetsInfoForSource(source: source)
                    }
                    else {
                        finish()
                    }
                }
            }
        )
        .modelContainer(viewModel.modelContainer)
    }

    private func makeSourceRow(source: SourceItem) -> some View {
        AnyView(
            HStack {
                SVGImageView(url: source.items.first!.resource.url, size: CGSize(width: 20, height: 20))
                    .frame(width: 20, height: 20)
                    .opacity(viewModel.isLoadingData ? 0.8 : 1.0)

                Text(source.items.first!.name)

                Spacer()

                if let selected = scopeViewModel.selectedSource, selected.id == source.id {
                    Image(systemName: "checkmark")
                }
            }
        )
    }

    private var scopingToggle: some View {
        HStack {
            Image(systemName: "scope")
                .frame(width: 30, height: 30, alignment: .center)
            Text("Limit your query")
            Spacer()
            Toggle("", isOn: $scopeViewModel.isScopeModificationAllowed)
                .onChange(of: scopeViewModel.isScopeModificationAllowed) { _, value in
                    if !value {
                        self.resetScopeOptions()
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(viewState == .sampleData ? Color("pickerBackgroundColor") : Color(.secondarySystemGroupedBackground))
        )
    }

    private var scopingPreview: some View {
        Button {
            scopeViewModel.shouldDisplayModal = true
        } label: {
            VStack(alignment: .center, spacing: 10) {
                scopeTitle

                Text("\(scopeViewModel.startDateFormatString) - \(scopeViewModel.endDateFormatString)")
                    .padding(.bottom, 10)
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .onChange(of: scopeViewModel.startDate) { _, newValue in
                        scopeViewModel.startDateFormatString = newValue == nil ? ScopeAddView.datePlaceholder : scopeViewModel.dateFormatter.string(from: newValue!)
                    }
                    .onChange(of: scopeViewModel.endDate) { _, newValue in
                        scopeViewModel.endDateFormatString = newValue == nil ? ScopeAddView.datePlaceholder : scopeViewModel.dateFormatter.string(from: newValue!)
                    }

                ScopeObjectTypesGridView(objectTypes: objectTypes)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
        }
    }

    private var sourcesHeaderView: some View {
        VStack(alignment: .leading) {
            // Title and Description
            VStack(alignment: .leading, spacing: 10) {
                Text("Connect a source")
                    .font(.title)
                    .bold()

                Text("You will be asked to login your selected source to approve access.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // Sample Data Box
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Not sure what to connect? Try with sample data first.")
                            .font(.headline)

                        Text("Play with sample data and when you’re ready you can start over and connect your own sources.")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Button {
                            pushNextView = true
                        } label: {
                            HStack(spacing: 10) {
                                Text("Try with Sample Data")

                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(navigationButtonStyle)
                    }

                    VStack {
                        Image("serviceIconRaw")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.top, 10)
                            .foregroundColor(.green)

                        Spacer()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.orange, lineWidth: 2)
            }
            .padding(.horizontal, 2)
            .navigationDestination(isPresented: $pushNextView) {
                SourcePickerView(showView: $showView, selectSourceCompletion: $selectSourceCompletion, viewModel: viewModel, scopeViewModel: scopeViewModel, viewState: .sampleData, allowScoping: allowScoping)
            }
        }
    }

    private var sampleDataHeaderView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")

                    Text("Switch back to use YOUR OWN data")
                }
            }
            .buttonStyle(navigationButtonStyle)

            // Title and Description
            Text("Select a sample source")
                .font(.title)
                .bold()

            // Sample Data Box
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("These are sample data sources.")
                        .font(.headline)

                    Text("Tap one to import a small sample set of content so you can explore how the app works.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Image("serviceIconRaw")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.top, 10)
                        .foregroundColor(.green)

                    Spacer()
                }
            }
        }
    }

    private var viewBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(viewState == .sampleData ? Color("pickerBackgroundColor") : Color("pickerItemColor"), lineWidth: 2)
    }

    private var scopeTitle: some View {
        HStack {
            Text("Your Scope time range. ")
                .foregroundColor(.primary)
                .font(.footnote) +
            Text("Tap to change:")
                .foregroundColor(.accentColor)
                .font(.footnote)
        }
    }

    private var buttonProceed: some View {
        GenericPressableButtonView(isPressed: $proceedButtonIsPressed) {
            if
                viewState == .sampleData,
                let selectedSource = scopeViewModel.selectedSource {

                viewModel.fetchDemoDataSetsInfoForSource(source: selectedSource)
            }
            else {
                finish()
            }
        } content: {
            Text("Add Service")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor)
                        .opacity(proceedDisabled || proceedButtonIsPressed ? 0.5 : 1)
                )
                .disabled(proceedDisabled)
        }
    }

    private var proceedDisabled: Bool {
        return viewModel.isLoadingData || (viewState == .sampleData && scopeViewModel.selectedSource == nil)
    }

    private var cancelButton: some View {
        Button {
            showView = false
        } label: {
            Text("Cancel")
        }
    }

    private var addServiceButton: some View {
        Button {
            if
                viewState == .sampleData,
                let selectedSource = scopeViewModel.selectedSource {

                viewModel.fetchDemoDataSetsInfoForSource(source: selectedSource)
            }
            else {
                finish()
            }
        } label: {
            Text("Add Service")
                .font(.headline)
                .foregroundColor(proceedDisabled ? .gray : .accentColor)
        }
        .disabled(proceedDisabled)
    }

    private func resetScopeOptions() {
        scopeViewModel.resetSettings()
    }

    private func finish(sampleDataset: String? = nil) {
        guard var source = scopeViewModel.selectedSource else {
            return
        }

        source.options = scopeViewModel.readOptions
        selectSourceCompletion?(source, sampleDataset)
        showView = false
        scopeViewModel.selectedSource = nil
    }

    private func customActionSheetPickerButtons() -> [CustomActionPickerViewButtonData] {
        guard let datasets = viewModel.sampleDatasets else {
            return []
        }

        let buttons = datasets.compactMap { key, dataset in
            CustomActionPickerViewButtonData(title: dataset.name.uppercased(),
                                             subtitle: dataset.description.isEmpty ? "A comprehensive set of data points for you to get a feel for a real user..." : dataset.description) {
                self.finish(sampleDataset: key)
            }
        }

        return buttons
    }
}

#Preview {
    let previewer = try? Previewer()
    let loggingService = LoggingService(modelContainer: previewer!.container)
    let servicesViewModel = ServicesViewModel(loggingService: loggingService, modelContainer: previewer!.container)
    return SourcePickerView(showView: .constant(true), selectSourceCompletion: .constant(nil), viewModel: servicesViewModel, scopeViewModel: ScopeViewModel(), viewState: .sources, allowScoping: true)
        .environmentObject(servicesViewModel)
        .modelContainer(previewer!.container)
        .environment(\.colorScheme, .dark)
}
