//
//  ServicePickerView.swift
//  DigiMeSDKExample
//
//  Created on 23/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import SwiftUI

struct ServicePickerView: View {
    @Binding var sections: [ServiceSection]
    @Binding var showView: Bool
    @Binding var selectServiceCompletion: ((Service) -> Void)?
    
    @ObservedObject var scopeViewModel: ScopeViewModel
        
    @State private var flags: [Bool] = []
    @State private var searchText: String = ""
    @State private var timeRangeTemplates: [TimeRangeTemplate] = TestTimeRangeTemplates.data
    @State private var objectTypes: [ServiceObjectType] = []
    
    var allowScoping: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    searchBar
                    content
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Add a Source", displayMode: .inline)
                .navigationBarItems(leading: cancelButton, trailing: addServiceButton)
                .onChange(of: searchText) { newValue in
                    flags = Array(repeating: !newValue.isEmpty, count: sections.count)
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
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            scopeViewModel.serviceSections = sections
            flags = sections.map { _ in false }
        }
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
    }
    
    func makeServiceRow(service: Service) -> some View {
        HStack {
            if let resource = service.resources.optimalResource(for: CGSize(width: 20, height: 20)) {
                SourceImage(url: resource.url)
            }
            else {
                Image(systemName: "photo.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }
            
            Text(service.name)
                .foregroundColor(.primary)
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
    }
    
    private var content: some View {
        ForEach(Array(sections.enumerated()), id: \.1.id) { i, section in
            Section {
                DisclosureGroup(isExpanded: $flags[i]) {
                    ForEach(searchText.isEmpty ? section.items : section.items.filter { $0.name.lowercased().contains(searchText.lowercased()) }) { service in
                        Button {
                            scopeViewModel.selectedService = service
                        } label: {
                            makeServiceRow(service: service)
                        }
                    }
                } label: {
                    HStack {
                        Image(section.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20, alignment: .center)
                        
                        Text(section.title)
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
                .fill(Color(.secondarySystemGroupedBackground))
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
                    .stroke(.blue, lineWidth: 1)
            )
        }
    }
    
    private var scopeTitle: some View {
        HStack {
            Text("Your Scope time range. ")
                .foregroundColor(.primary)
                .font(.footnote) +
            Text("Tap to change:")
                .foregroundColor(.blue)
                .font(.footnote)
        }
    }
    
    private var buttonProceed: some View {
        Button {
            finish()
        } label: {
            Text("Add Service")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(scopeViewModel.selectedService == nil ? .gray : .accentColor)
                        .opacity(scopeViewModel.selectedService == nil ? 0.5 : 1)
                )
        }
        .disabled(scopeViewModel.selectedService == nil)
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
            finish()
        } label: {
            Text("Add Service")
                .font(.headline)
                .foregroundColor(scopeViewModel.selectedService == nil ? .gray : .accentColor)
        }
    }
    
    private func reset() {
        scopeViewModel.resetSettings()
    }
    
    private func finish() {
        guard var service = scopeViewModel.selectedService else {
            return
        }
        
        service.options = scopeViewModel.readOptions
        selectServiceCompletion?(service)
        showView = false
    }
}

struct ServicePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ServicePickerView(sections: .constant([]), showView: .constant(true), selectServiceCompletion: .constant(nil), scopeViewModel: ScopeViewModel(), allowScoping: true)
//            .environment(\.colorScheme, .dark)
    }
}
