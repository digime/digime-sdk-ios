//
//  ServicePickerView.swift
//  DigiMeSDKExample
//
//  Created on 23/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import Foundation
import SwiftUI

struct ServicePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showView: Bool
    @Binding var selectServiceCompletion: ((Service, String?) -> Void)?
    
    @ObservedObject var viewModel: ServicesViewModel
    @ObservedObject var scopeViewModel: ScopeViewModel
    
    @State var viewState: ConnectSourceViewState
    @State private var showSampleDataSetActionSheet = false
    @State private var showSampleDataErrorActionSheet = false
    @State private var proceedSampleDataset = false
    @State private var pushNextView: Bool = false
    @State private var proceedButtonIsPressed: Bool = false
    @State private var flags: [Bool] = []
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

    private var filteredSections: [ServiceSection] {
        return viewState == .sampleData ? viewModel.sampleDataSections : viewModel.serviceSections
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
                .onChange(of: searchText) { newValue in
                    flags = Array(repeating: !newValue.isEmpty, count: filteredSections.count)
                }
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
                
                if allowScoping {
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
            scopeViewModel.serviceSections = filteredSections
            flags = filteredSections.map { _ in false }

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
        .onChange(of: scopeViewModel.selectedService) { newValue in
            guard
                let service = newValue,
                let groupId = service.serviceGroupIds.first,
                let data = TestServiceObjectTypesByGroups.data.first(where: { $0.id == groupId })?.items else {
                return
            }
            
            scopeViewModel.objectTypes = data
            scopeViewModel.selectedObjectTypes = Set(data.map { $0.id })
        }
        .onChange(of: scopeViewModel.selectedObjectTypes) { newValue in
            objectTypes = scopeViewModel.objectTypes.filter { newValue.contains($0.id) }
        }
        .onChange(of: proceedSampleDataset) { _ in
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
                    if let url = URL(string: "mailto:support@digi.me?subject=I'd like a sample dataset for \(scopeViewModel.selectedService?.name ?? "a service")") {
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
    
    func makeServiceRow(service: Service) -> some View {
        HStack {
            if
                let resource = service.resources.svgResource() {
                ImageDownloaderView(url: resource.url, size: CGSize(width: 20, height: 20))
                    .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
            }
            else if let resource = ResourceUtility.optimalResource(for: CGSize(width: 20, height: 20), from: service.resources) {
                SourceImage(url: resource.url)
                    .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
            }
            else {
                Image(systemName: "photo.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }
            
            Text(service.name)
            
            Spacer()
            
            if
                let selected = scopeViewModel.selectedService,
                selected.identifier == service.identifier {
                
                Image(systemName: "checkmark")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search ...", text: $searchText)
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
    
    private var content: some View {
        LazyVStack {
            ForEach(Array(filteredSections.enumerated()), id: \.1.id) { i, section in
                Section {
                    Button(action: {
                        flags[i].toggle()
                    }) {
                        HStack {
                            Image(section.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .leading)
                                .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
                                .disabled(viewModel.isLoadingData)
                            
                            Text(section.title)
                                .foregroundColor(viewModel.isLoadingData ? .gray : .primary)
                            
                            Spacer()
                            
                            if !flags.isEmpty {
                                Image(systemName: flags[i] ? "chevron.down" : "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(viewModel.isLoadingData ? .gray : .primary)
                            }
                        }
                        .padding(15)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(viewBackground)
                        .padding(.horizontal, 2)
                    }
                    .padding(.vertical, 5)
                    .disabled(viewModel.isLoadingData)
                    
                    if !flags.isEmpty, flags[i] {
                        ForEach(searchText.isEmpty ? section.items : section.items.filter { $0.name.lowercased().contains(searchText.lowercased()) }) { service in
                            Button {
                                guard !viewModel.isLoadingData else {
                                    return
                                }
                                
                                scopeViewModel.selectedService = service
                                viewModel.sampleDatasets = nil
                                
                                if !allowScoping {
                                    if viewState == .sampleData {
                                        viewModel.fetchDemoDataSetsInfoForService(service: service)
                                    }
                                    else {
                                        finish()
                                    }
                                }
                                    
                                } label: {
                                makeServiceRow(service: service)
                            }
                            .buttonStyle(servicesButtonStyle)
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
    
    private var scopingToggle: some View {
        HStack {
            Image(systemName: "scope")
                .frame(width: 30, height: 30, alignment: .center)
            Text("Limit your query")
            Spacer()
            Toggle("", isOn: $scopeViewModel.isScopeModificationAllowed)
                .onChange(of: scopeViewModel.isScopeModificationAllowed) { value in
                    if !value {
                        self.reset()
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
                    .onChange(of: scopeViewModel.startDate) { newValue in
                        scopeViewModel.startDateFormatString = newValue == nil ? ScopeAddView.datePlaceholder : scopeViewModel.dateFormatter.string(from: newValue!)
                    }
                    .onChange(of: scopeViewModel.endDate) { newValue in
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
                            pushNextView.toggle()
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
                ServicePickerView(showView: $showView, selectServiceCompletion: $selectServiceCompletion, viewModel: viewModel, scopeViewModel: scopeViewModel, viewState: .sampleData, allowScoping: allowScoping)
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
        GenericPressableButtonView(isPressed: $proceedButtonIsPressed, action: {
            if
                viewState == .sampleData,
                let selectedService = scopeViewModel.selectedService {

                viewModel.fetchDemoDataSetsInfoForService(service: selectedService)
            }
            else {
                finish()
            }
        }) {
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
        return viewModel.isLoadingData || (viewState == .sampleData && scopeViewModel.selectedService == nil)
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
                let selectedService = scopeViewModel.selectedService {
                
                viewModel.fetchDemoDataSetsInfoForService(service: selectedService)
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
    
    private func reset() {
        scopeViewModel.resetSettings()
    }
    
    private func finish(sampleDataset: String? = nil) {
        guard var service = scopeViewModel.selectedService else {
            return
        }
        
        service.options = scopeViewModel.readOptions
        selectServiceCompletion?(service, sampleDataset)
        showView = false
        scopeViewModel.selectedService = nil
    }
    
    private func actionSheetButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []

        viewModel.sampleDatasets?.forEach { (key, dataset) in
            let button = ActionSheet.Button.default(Text(dataset.name.uppercased())) {
                self.finish(sampleDataset: key)
            }
            buttons.append(button)
        }

        buttons.append(.cancel())
        return buttons
    }

    private func customActionSheetPickerButtons() -> [CustomActionPickerViewButtonData] {
        guard let datasets = viewModel.sampleDatasets else {
            return []
        }

        let buttons = datasets.compactMap { (key, dataset) in
            CustomActionPickerViewButtonData(title: dataset.name.uppercased(),
                                       subtitle: dataset.description.isEmpty ? "A comprehensive set of data points for you to get a feel for a real user..." : dataset.description, 
                                       action: {
                self.finish(sampleDataset: key)
            })
        }

        return buttons
    }
}

struct SourceSelectorButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var padding: CGFloat
    var strokeColor: Color

    init(backgroundColor: Color, foregroundColor: Color, padding: CGFloat, strokeColor: Color = .clear) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.padding = padding
        self.strokeColor = strokeColor
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(padding)
            .foregroundColor(configuration.isPressed ? .white : foregroundColor)
            .background(configuration.isPressed ? .accentColor : backgroundColor)
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(strokeColor, lineWidth: configuration.isPressed ? 0 : 2)
            }
    }
}

struct ServicePickerView_Previews: PreviewProvider {
    static var previews: some View {
        let sections = TestDiscoveryObjects.sections
        ServicePickerView(showView: .constant(true), selectServiceCompletion: .constant(nil), viewModel: ServicesViewModel(sections: sections), scopeViewModel: ScopeViewModel(), viewState: .sources, allowScoping: true)
//            .environment(\.colorScheme, .dark)
    }
}
