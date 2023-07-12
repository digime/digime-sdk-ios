//
//  ScopeAddView.swift
//  DigiMeSDKExample
//
//  Created on 23/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct ScopeAddView: View {
    static let datePlaceholder = "__ . __ . ____"
    
    @ObservedObject var viewModel: ScopeViewModel
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Section(footer: Text("Please select a date range for the data query. When you select the appropriate option from the list the sample date range will be displayed.")) {
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
                    
                    Section(footer: Text("Please select the service object types to limit your data query.")) {
                        ScopeServiceObjectTypesRow(viewModel: viewModel)
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

struct ScopeView_Previews: PreviewProvider {
    static var previews: some View {
        ScopeAddView(viewModel: ScopeViewModel())
    }
}
