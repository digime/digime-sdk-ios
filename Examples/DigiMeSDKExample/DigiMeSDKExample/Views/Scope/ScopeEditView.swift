//
//  ScopeEditView.swift
//  DigiMeSDKExample
//
//  Created on 11/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ScopeEditView: View {
    @ObservedObject var viewModel: ScopeViewModel
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Section(footer: Text("Please select a date range for the data query. Once you select an option from the list, a sample date range will be displayed.")) {
                        ScopeTimeRangeTemplatesRow(viewModel: viewModel)
                    }
                    
                    Section(header: Text("Limit Duration for Data Fetch Quota"), footer: Text("The 'Limits' property allows you to specify the maximum duration for fetching source data during a sync process (in seconds). The default is 'unlimited', which effectively equates to 3600 seconds due to the sync limit. However, it may take longer as it waits for sync completion.")) {
                        NavigationLink {
                            ScopeLimitsDetailsView(viewModel: viewModel)
                        } label: {
                            HStack {
                                let sourceFetch = viewModel.selectedDuration.sourceFetch
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Duration (sec)")
                                Spacer()
                                Text(sourceFetch == 0 ? "unlimited" : (sourceFetch >= 60 ? "\(sourceFetch / 60) min" : "\(sourceFetch) sec"))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if !viewModel.linkedAccounts.isEmpty {
                        Section(header: Text("Service Object Types"), footer: Text("Use this option to parameterize the sync process to retrieve data only from the selected Object Types.")) {
                            accounts
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Limit Your Query", displayMode: .inline)
                .navigationBarItems(leading: resetButton, trailing: doneButton)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .overlay((viewModel.shouldDisplayStartDatePicker || viewModel.shouldDisplayEndDatePicker) ? .black.opacity(0.4) : .clear)
            .blur(radius: (viewModel.shouldDisplayStartDatePicker || viewModel.shouldDisplayEndDatePicker) ? 3 : 0)
            .padding(-5)
            
            if viewModel.shouldDisplayStartDatePicker {
                withAnimation(.easeOut) {
                    DatePickerWithButtons(showDatePicker: $viewModel.shouldDisplayStartDatePicker, showTime: $viewModel.shouldDisplayTimeOption, date: $viewModel.startDate.toUnwrapped(defaultValue: Date()))
                        .shadow(radius: 20)
                        .transition(.move(edge: .bottom))
                }
            }

            if viewModel.shouldDisplayEndDatePicker {
                withAnimation(.easeOut) {
                    DatePickerWithButtons(showDatePicker: $viewModel.shouldDisplayEndDatePicker, showTime: $viewModel.shouldDisplayTimeOption, date: $viewModel.endDate.toUnwrapped(defaultValue: Date()))
                        .shadow(radius: 20)
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    private var accounts: some View {
        ForEach(Array(viewModel.linkedAccounts.enumerated()), id: \.1.id) { i, connectedAccount in
            Section {
                DisclosureGroup(isExpanded: $viewModel.flags[i]) {
                    ForEach(connectedAccount.defaultObjectTypes) { objectType in
                        let objectTypeName = objectType.name ?? "n/a"
                        VStack {
                            HStack {
                                ScopeObjectTypeIconView(name: objectTypeName, size: 35)
                                    .padding(.trailing, 5)

                                Text(objectTypeName)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if connectedAccount.selectedObjectTypeIds.contains(objectType.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }

                                Spacer()
                            }
                            .frame(minHeight: 40)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let selected = !connectedAccount.selectedObjectTypeIds.contains(objectType.id)
                                viewModel.refreshConnectedAccount(for: connectedAccount.id, objectTypeId: objectType.id, selected: selected)
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let resource = ResourceUtility.optimalResource(for: CGSize(width: 20, height: 20), from: connectedAccount.service.resources) {
                            SourceImage(url: resource.url)
                        }
                        else {
                            Image(systemName: "photo.circle.fill")
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }

                        Text(connectedAccount.service.name)
                    }
                }
            }
        }
    }
    
    var doneButton: some View {
        Button {
            viewModel.completeProcess()
        } label: {
            Text("Done")
                .font(.headline)
        }
    }
    
    var resetButton: some View {
        Button {
            viewModel.resetSettings()
        } label: {
            Text("Reset")
        }
    }
}

struct ScopeEditView_Previews: PreviewProvider {
    static var previews: some View {
        ScopeEditView(viewModel: ScopeViewModel())
    }
}
