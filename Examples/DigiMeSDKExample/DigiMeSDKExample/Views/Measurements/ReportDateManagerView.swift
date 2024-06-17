//
//  ReportDateManagerView.swift
//  DigiMeSDKExample
//
//  Created on 28/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftData
import SwiftUI

enum ReportOption {
    case none
    case thisWeek
    case thisMonth
    case thisYear
    case everything
    case custom
}

enum DateManagerViewType: Int {
    case portability = 0
    case measurement = 1
    case appleHealth = 2
}

struct ReportDateManagerView: View {
    @Environment(\.presentationMode) var presentationMode

    @Query(sort: [
        SortDescriptor(\SelfMeasurement.createdDate, order: .reverse)
    ]) var measurements: [SelfMeasurement]

    @State private var showTimeOption = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showAlert = false
    @State private var selectedOption: ReportOption = .custom
    @State private var minDate: Date?
    @State private var alert: NotifyBanner?
    @State private var fileURL: URL?

    @Binding var navigationPath: NavigationPath
    @Binding var startDate: Date
    @Binding var endDate: Date

    var viewType: DateManagerViewType = .appleHealth
    var shareLocally = false
    var onProceed: (() -> Void)?

    private var formatter: DateFormatter {
        let fm = DateFormatter()
        fm.dateStyle = .medium
        fm.timeStyle = .none
        return fm
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if viewType != .appleHealth {
                        Text(mainTitle)
                            .fontWeight(.black)
                            .font(.title)
                            .padding(.bottom, 14)
                    }

                    if viewType == .portability {
                        Text("Quick Reports")
                            .fontWeight(.bold)
                            .padding(.bottom, 14)
                    }

                    optionButton(title: "This Week", selectedOption: .thisWeek, dateRange: DateRange.thisWeek)
                    optionButton(title: "This Month", selectedOption: .thisMonth, dateRange: DateRange.thisMonth)
                    optionButton(title: "This Year", selectedOption: .thisYear, dateRange: DateRange.thisYear)

                    if viewType == .measurement || viewType == .appleHealth {
                        optionButton(title: "Everything", selectedOption: .everything, dateRange: DateRange.everything)
                            .padding(.bottom, 14)
                    }

                    VStack(alignment: .leading) {
                        Text("Custom Period")
                            .fontWeight(.bold)
                            .padding(.horizontal, 15)
                            .padding(.top, 20)

                        dateSelectionButton(title: "From", date: $startDate, showDatePicker: $showStartDatePicker)
                        dateSelectionButton(title: "To", date: $endDate, showDatePicker: $showEndDatePicker)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(selectedOption == .custom ? Color.blue : Color.clear, lineWidth: 2)
                    )

                    Button {
                        onProceed?()
                    } label: {
                        HStack {
                            Text(actionTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.white)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(Color.accentColor)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    Text(footer)
                        .padding(.horizontal, 20)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(20)
            }
            .disabled(showStartDatePicker || showEndDatePicker)
            .overlay(
                Group {
                    if showStartDatePicker || showEndDatePicker {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showStartDatePicker = false
                                    showEndDatePicker = false
                                }
                            }
                    }
                }
            )

            if showStartDatePicker {
                DatePickerWithButtons(showDatePicker: $showStartDatePicker, showTime: $showTimeOption, date: $startDate, maxDate: endDate)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }

            if showEndDatePicker {
                DatePickerWithButtons(showDatePicker: $showEndDatePicker, showTime: $showTimeOption, date: $endDate, minDate: startDate)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .onAppear {
            guard viewType == .measurement else {
                return
            }

            self.selectedOption = self.calculateDefaultMaxRange()
            self.startDate = self.minDate ?? Date()

            if self.selectedOption == .none {
                self.showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("You have no measurements to share"), dismissButton: .default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationBarTitle(navigationBarTitle, displayMode: .large)
        .bannerView(toast: $alert)
    }

    private func optionButton(title: String, selectedOption: ReportOption, dateRange: DateRange) -> some View {
        Button {
            (startDate, endDate) = dateRange.dates
            self.selectedOption = selectedOption
        } label: {
            HStack {
                Text(title)
                Spacer()
                if self.selectedOption == selectedOption {
                    Image(systemName: "checkmark")
                }
            }
            .foregroundColor(.primary)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(self.selectedOption == selectedOption ? Color.blue.opacity(0.2) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(self.selectedOption == selectedOption ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }

    private func dateSelectionButton(title: String, date: Binding<Date>, showDatePicker: Binding<Bool>) -> some View {
        Button {
            self.selectedOption = .custom
            withAnimation {
                showDatePicker.wrappedValue.toggle()
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(formatter.string(from: date.wrappedValue))
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }

    private var mainTitle: String {
        switch viewType {
        case .portability:
            return "Select the Time Period for Your Report"
        case .measurement:
            return "Share Measurements for"
        case .appleHealth:
            return ""
        }
    }

    private var actionTitle: String {
        switch viewType {
        case .portability:
            return "Generate Report"
        case .measurement:
            return "Select Destination"
        case .appleHealth:
            return "Next"
        }
    }

    private var navigationBarTitle: String {
        switch viewType {
        case .portability:
            return "Portability Report"
        case .measurement:
            return "Share Measurements"
        case .appleHealth:
            return "Select Time Period"
        }
    }

    private var footer: String {
        switch viewType {
        case .portability:
            return "Portability Report"
        case .measurement:
            return shareLocally ? "You will be able to select your local destination" : "You will be able to select the GP or Hospital you would like to share with."
        case .appleHealth:
            return "On the next step you are going to start fetching your Apple Health data and then you need to select the items you want to push to your cloud library."
        }
    }

    private func calculateDefaultMaxRange() -> ReportOption {
        guard
            !measurements.isEmpty,
            let earliestMeasurementDate = measurements.compactMap({ $0.createdDate }).min() else {
            return .none
        }

        let calendar = Calendar.current
        let today = Date()
        minDate = earliestMeasurementDate
        
        if calendar.isDate(earliestMeasurementDate, equalTo: today, toGranularity: .weekOfYear) {
            return .thisWeek
        }
        else if calendar.isDate(earliestMeasurementDate, equalTo: today, toGranularity: .month) {
            return .thisMonth
        }
        else if calendar.isDate(earliestMeasurementDate, equalTo: today, toGranularity: .year) {
            return .thisYear
        }
        else {
            return .everything
        }
    }

    private func notify() {
        alert = NotifyBanner(type: .error, title: "Error", message: "Failed to export your self-measurements.")
    }

    private struct DateRange {
        let dates: (Date, Date)

        static var thisWeek: DateRange {
            let date = Date()
            let components = Calendar.current.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
            let startDate = Calendar.current.date(from: components)!
            return DateRange(dates: (startDate, date))
        }

        static var thisMonth: DateRange {
            let date = Date()
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            let startDate = Calendar.current.date(from: components)!
            return DateRange(dates: (startDate, date))
        }

        static var thisYear: DateRange {
            let components = Calendar.current.dateComponents([.year], from: Date())
            let startDate = Calendar.current.date(from: components)!
            return DateRange(dates: (startDate, Date()))
        }

        static var everything: DateRange {
            let startDate = Date.date(year: 1970, month: 1, day: 1)
            return DateRange(dates: (startDate, Date()))
        }
    }
}

#Preview {
    NavigationStack {
        ReportDateManagerView(navigationPath: .constant(NavigationPath()), startDate: .constant(Date()), endDate: .constant(Date()), viewType: DateManagerViewType.appleHealth)
//            .environment(\.colorScheme, .dark)
    }
}
