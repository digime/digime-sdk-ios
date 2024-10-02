//
//  ReportDateManagerView.swift
//  DigiMeSDKExample
//
//  Created on 28/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
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

struct ReportDateManagerView: View {
    @StateObject private var viewModel: HealthDataViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var showPermissionView = false
    @State private var showTimeOption = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showAlert = false
    @State private var showProgressView = false
    @State private var showExportItemsView = false
    @State private var selectedOption: ReportOption = .custom
    @State private var minDate: Date?
    @State private var alert: NotifyBanner?
    @State private var fileURL: URL?
    @State private var startDate: Date = DateRange.lastYear.dates.0
    @State private var endDate: Date = DateRange.lastYear.dates.1

    @Binding var navigationPath: NavigationPath

    var shareLocally = false

    private var formatter: DateFormatter {
        let fm = DateFormatter()
        fm.dateStyle = .medium
        fm.timeStyle = .none
        return fm
    }

    private var dateRange: (start: Date, end: Date) {
        switch selectedOption {
        case .thisWeek:
            return DateRange.thisWeek.dates
        case .thisMonth:
            return DateRange.thisMonth.dates
        case .thisYear:
            return DateRange.thisYear.dates
        case .everything:
            return DateRange.everything.dates
        case .custom:
            return DateRange.lastYear.dates
        case .none:
            return (Date(), Date())
        }
    }

    init(
        viewModel: HealthDataViewModel,
        navigationPath: Binding<NavigationPath> = .constant(NavigationPath()),
        startDate: Date = DateRange.lastYear.dates.0,
        endDate: Date = DateRange.lastYear.dates.1,
        shareLocally: Bool = false
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigationPath = navigationPath
        self._startDate = State(wrappedValue: startDate)
        self._endDate = State(wrappedValue: endDate)
        self.shareLocally = shareLocally
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea([.all])
            NavigationStack(path: $navigationPath) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(mainTitle)
                            .fontWeight(.black)
                            .font(.title)

                        Text(mainDescription)
                            .font(.footnote)

                        optionButton(title: "thisWeek".localized(), selectedOption: .thisWeek)
                        optionButton(title: "thisMonth".localized(), selectedOption: .thisMonth)
                        optionButton(title: "thisYear".localized(), selectedOption: .thisYear)
                        optionButton(title: "everything".localized(), selectedOption: .everything)
                                .padding(.bottom, 14)

                        VStack(alignment: .leading) {
                            Text("customPeriod".localized())
                                .fontWeight(.bold)
                                .padding(.horizontal, 15)
                                .padding(.top, 20)

                            dateSelectionButton(title: "from".localized(), date: $startDate, showDatePicker: $showStartDatePicker)
                            dateSelectionButton(title: "to".localized(), date: $endDate, showDatePicker: $showEndDatePicker)
                                .padding(.bottom)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedOption == .custom ? Color.blue.opacity(0.2) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(selectedOption == .custom ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            self.selectedOption = .custom
                            updateDates()
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            Text("dataAggregationOption".localized())
                                .fontWeight(.bold)
                                .padding(.horizontal, 15)
                                .padding(.top, 20)


                            if viewModel.aggregationOption != AggregationType.none {
                                Text("dataAggregationDescription".localized())
                                    .font(.callout)
                                    .padding(.horizontal, 15)
                            }

                            aggregationSelector
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(viewModel.aggregationOption == AggregationType.none ? Color(.systemGray6) : Color.blue.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(viewModel.aggregationOption == AggregationType.none ? Color.clear : Color.blue, lineWidth: 2)
                        )

                        Button {
                            guard !viewModel.isLoadingData else {
                                return
                            }
                            
                            Task {
                                await viewModel.resetAllData()
                                await MainActor.run {
                                    viewModel.startDate = startDate
                                    viewModel.endDate = endDate
                                    viewModel.loadAppleHealth()
                                    showProgressView = true
                                }
                            }
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
                        .disabled(!viewModel.canProceed)

                        Text(footer)
                            .padding(.horizontal, 20)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                }
            }
            .onAppear {
                self.selectedOption = .custom
                let initialRange = DateRange.lastYear.dates
                startDate = initialRange.0
                endDate = initialRange.1

                if self.selectedOption == .custom {
                    updateDates()
                }

                if self.selectedOption == .none {
                    self.showAlert = true
                }
            }
            .onChange(of: selectedOption) { _, _ in
                updateDates()
            }
            .onChange(of: viewModel.showErrorBanner) {
                showErrorMessage()
            }
            .onChange(of: viewModel.showSuccessBanner) {
                showSuccessMessage()
            }
            .sheet(isPresented: $viewModel.shareLocally) {
                ShareSheetView(shareItems: viewModel.shareUrls ?? [])
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showPermissionView) {
                NavigationView {
                    HealthDataPermissionView(viewModel: viewModel)
                        .navigationBarTitle("healthData".localized(), displayMode: .inline)
                        .navigationBarItems(trailing: Button("done".localized()) {
                            showPermissionView = false
                        })
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .sheet(isPresented: $showExportItemsView) {
                NavigationView {
                    HealthDataExportItemsView(viewModel: viewModel, navigationPath: $navigationPath, startDate: $startDate, endDate: $endDate, showModal: $showExportItemsView)
                        .modelContainer(viewModel.modelContainer)
                        .navigationBarTitle("healthData".localized(), displayMode: .inline)
                        .navigationBarItems(trailing: Button("done".localized()) {
                            showExportItemsView = false
                        })
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .overlay(
                HealthDataProgressView(viewModel: viewModel, actionTitle: $viewModel.progressMessage, isPresented: $showProgressView) {
                    viewModel.exportAutomatically = false
                    showExportItemsView = true
                }
            )
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if viewModel.isLoadingData {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .frame(width: 20, height: 20)
                    }
                    else {
                        Button {
                            showPermissionView = true
                        } label: {
                            Image(systemName: "checklist")
                        }
                    }
                }
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("noMeasurementsToShare".localized()), dismissButton: .default(Text("ok".localized())) {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationBarTitle(navigationBarTitle, displayMode: .inline)
        .bannerView(toast: $alert)
    }

    private var aggregationSelector: some View {
        Picker("", selection: $viewModel.aggregationOption) {
            Text("none".localized()).tag(AggregationType.none)
            Text("daily".localized()).tag(AggregationType.daily)
            Text("weekly".localized()).tag(AggregationType.weekly)
            Text("monthly".localized()).tag(AggregationType.monthly)
            Text("yearly".localized()).tag(AggregationType.yearly)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func updateDates() {
        let newRange = dateRange
        if selectedOption != .custom {
            startDate = newRange.start
            endDate = newRange.end
        }
    }

    private func optionButton(title: String, selectedOption: ReportOption) -> some View {
        Button {
            self.selectedOption = selectedOption
            updateDates()
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
                    .fill(selectedOption == .custom ? .white : Color(.systemGray5))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }

    private var navigationBarTitle: String {
        return "healthData".localized()
    }

    private var mainTitle: String {
        return "healthDataImportSummary".localized()
    }

    private var mainDescription: String {
        return "dateSelectorDescription".localized()
    }

    private var actionTitle: String {
        return "importNow".localized()
    }

    private var footer: String {
        return ""
    }

    private func notify() {
        alert = NotifyBanner(type: .error, title: "error".localized(), message: "failedToExportSelfMeasurements".localized())
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

        static var lastYear: DateRange {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -365, to: endDate)!
            return DateRange(dates: (startDate, endDate))
        }

        static var everything: DateRange {
            let startDate = Date.date(year: 1970, month: 1, day: 1)
            return DateRange(dates: (startDate, Date()))
        }
    }

    private func showSuccessMessage() {
        if let message = viewModel.successMessage {
            alert = NotifyBanner(type: .success, title: "success".localized(), message: message, duration: 5)
        }
    }

    private func showErrorMessage() {
        if let error = viewModel.error as? SDKError {
            alert = NotifyBanner(type: .error, title: "error".localized(), message: error.description, duration: 5)
        }
        else if let message = viewModel.error?.localizedDescription {
            alert = NotifyBanner(type: .error, title: "error".localized(), message: message, duration: 5)
        }
    }
}

#Preview {
    NavigationStack {
        let previewer = try? Previewer()
        let viewModel = HealthDataViewModel(modelContainer: previewer!.container, cloudId: "CloudId", onComplete: nil)
        ReportDateManagerView(viewModel: viewModel, navigationPath: .constant(NavigationPath()), startDate: Date(), endDate: Date())
    }
}
