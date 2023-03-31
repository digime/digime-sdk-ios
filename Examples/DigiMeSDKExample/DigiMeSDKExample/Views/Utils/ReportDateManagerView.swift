//
//  ReportDateManagerView.swift
//  DigiMeSDKExample
//
//  Created on 28/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct ReportDateManagerView: View {
    @Binding var presentViewModally: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var showTimeOption = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    let onSuccess: (() -> Void)?
    
    private var formatter: DateFormatter {
        let fm = DateFormatter()
        fm.dateStyle = .medium
        fm.timeStyle = .none
        return fm
    }
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select the time period for your report")
                            .fontWeight(.black)
                            .font(.title)
                            .padding(.bottom, 14)
                        
                        Text("Quick Reports")
                            .fontWeight(.bold)
                            .padding(.bottom, 14)
                        
                        Button {
                            endDate = Date()
                            let components = Calendar.current.dateComponents([.year, .month], from: endDate)
                            startDate = Calendar.utcCalendar.date(from: components)!
                            presentViewModally.toggle()
                            onSuccess?()
                        } label: {
                            HStack {
                                Text("This Month")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        
                        Button {
                            endDate = Date()
                            let components = Calendar.current.dateComponents([.year], from: endDate)
                            startDate = Calendar.utcCalendar.date(from: components)!
                            presentViewModally.toggle()
                            onSuccess?()
                        } label: {
                            HStack {
                                Text("This Year")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        
                        Button {
                            startDate = Date.date(year: 1970, month: 1, day: 1)
                            endDate = Date()
                            presentViewModally.toggle()
                            onSuccess?()
                        } label: {
                            HStack {
                                Text("All Time")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .padding(.bottom, 14)
                        
                        Text("Or select a custom period")
                            .fontWeight(.bold)
                            .padding(.bottom, 14)
                        
                        VStack {
                            Button {
                                withAnimation {
                                    showStartDatePicker.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("From")
                                    Spacer()
                                    Text(formatter.string(from: startDate))
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(Color(.systemGray4))
                                        )
                                }
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(.systemGray5))
                                )
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            
                            Button {
                                withAnimation {
                                    showEndDatePicker.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("To")
                                    Spacer()
                                    Text(formatter.string(from: endDate))
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(Color(.systemGray4))
                                        )
                                }
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(.systemGray5))
                                )
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 10)
                            
                            Button {
                                presentViewModally.toggle()
                                onSuccess?()
                            } label: {
                                HStack {
                                    Text("Generate Report")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(15)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.accentColor)
                                )
                            }
                            .padding(.bottom, 20)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .navigationBarTitle("Portability Report", displayMode: .inline)
                    .navigationBarItems(trailing: cancelButton)
                    .padding(20)
                }
            }
            .overlay((showStartDatePicker || showEndDatePicker) ? .black.opacity(0.4) : .clear)
            .blur(radius: (showStartDatePicker || showEndDatePicker) ? 3 : 0)
            .padding(-5)
			.navigationViewStyle(StackNavigationViewStyle())
            
            if showStartDatePicker {
                withAnimation(.spring()) {
                    DatePickerWithButtons(showDatePicker: $showStartDatePicker, showTime: $showTimeOption, date: $startDate)
                        .shadow(radius: 20)
                        .offset(y: self.showStartDatePicker ? 0 : UIScreen.main.bounds.height)
                }
            }
            
            if showEndDatePicker {
                withAnimation(.easeOut) {
                    DatePickerWithButtons(showDatePicker: $showEndDatePicker, showTime: $showTimeOption, date: $endDate)
                        .shadow(radius: 20)
                        .offset(y: self.showEndDatePicker ? 0 : UIScreen.main.bounds.height)
                }
            }
        }
    }
    
    var cancelButton: some View {
        Button {
            presentViewModally.toggle()
        } label: {
            Text("Cancel")
                .font(.headline)
        }
    }
}

struct PortabilityReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReportDateManagerView(presentViewModally: .constant(false), startDate: .constant(Date()), endDate: .constant(Date()), onSuccess: nil)
        }
    }
}
