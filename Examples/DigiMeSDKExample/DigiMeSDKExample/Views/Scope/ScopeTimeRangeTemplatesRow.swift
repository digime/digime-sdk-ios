//
//  ScopeTimeRangeTemplatesRow.swift
//  DigiMeSDKExample
//
//  Created on 10/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ScopeTimeRangeTemplatesRow: View {
    @ObservedObject var viewModel: ScopeViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .frame(width: 30, height: 30, alignment: .center)
            Text("Time Range Templates")
            Spacer()
        }
        
        VStack {
            Picker(selection: $viewModel.selectedTimeRangeIndex, label: Text("")) {
                ForEach(0 ..< viewModel.timeRangeTemplates.count, id: \.self) {
                    Text(self.viewModel.timeRangeTemplates[$0].name)
                        .font(.callout)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 130, alignment: .center)
            .pickerStyle(WheelPickerStyle())
            .onAppear {
                self.viewModel.refreshUserInterface()
            }
            .onChange(of: viewModel.selectedTimeRangeIndex) { _ in
                self.viewModel.refreshUserInterface()
            }
            
            if !viewModel.showCustomDateOptions {
                Text("Your selected time range: ")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.startDateFormatString) - \(viewModel.endDateFormatString)")
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .padding(.top, 1)
            }
        }
        .padding()
        
        if viewModel.showCustomDateOptions {
            let image = Image(systemName: "calendar.badge.clock")
            ScopeDateButton(showModal: $viewModel.shouldDisplayStartDatePicker, date: $viewModel.startDate, formatter: viewModel.dateFormatter, actionButtonTitle: "Start", imageIcon: image.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)))
            ScopeDateButton(showModal: $viewModel.shouldDisplayEndDatePicker, date: $viewModel.endDate, formatter: viewModel.dateFormatter, actionButtonTitle: "End", imageIcon: image)
        }
    }
}

struct ScopeTimeRangeTemplatesRow_Previews: PreviewProvider {
    static var previews: some View {
        ScopeTimeRangeTemplatesRow(viewModel: ScopeViewModel())
    }
}
