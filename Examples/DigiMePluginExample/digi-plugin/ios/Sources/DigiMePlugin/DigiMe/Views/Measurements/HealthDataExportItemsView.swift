//
// HealthDataExportItemsView.swift
//  DigiMeSDKExample
//
//  Created on 03/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeHealthKit
import SwiftData
import SwiftUI

struct HealthDataExportItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: HealthDataViewModel

    @Binding var navigationPath: NavigationPath
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedHealthDataTypes: [QuantityType]?

    @State private var importFinished = false
    @State private var exportInProgress = false
    @State private var alert: NotifyBanner?
    @State private var importRefresher: Timer?
    @State private var importStartTime: Date?
    @State private var elapsedTime: String?
    @State private var maxDateRange: String?

    @Query(sort: [
        SortDescriptor(\HealthDataExportSection.typeIdentifier, order: .reverse)
    ]) private var sections: [HealthDataExportSection]

    private var readyToExport: Bool {
        return !viewModel.isLoadingData && importFinished && sections.contains { $0.itemsCount > 0 }
    }

    private static let formatter: DateFormatter = {
        let fm = DateFormatter()
        fm.dateStyle = .medium
        fm.timeStyle = .short
        return fm
    }()

    private static let formatterShort: DateFormatter = {
        let fm = DateFormatter()
        fm.dateStyle = .short
        fm.timeStyle = .none
        return fm
    }()

    private static let intervalFormatter: DateComponentsFormatter = {
        let fm = DateComponentsFormatter()
        fm.allowedUnits = [.hour, .minute, .second]
        fm.unitsStyle = .abbreviated
        fm.zeroFormattingBehavior = .pad
        return fm
    }()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    content

                    if readyToExport {
                        actionUploadButton
                        startOverButton
                    }
                    else {
                        actionLoadDataButton
                    }

                    footer
                }
            }
            .padding(20)
            .scrollIndicators(.hidden)
        }
        .toolbar {
            ToolbarItemGroup {
                if viewModel.isLoadingData {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .frame(width: 20, height: 20)
                }
                else if readyToExport {
                    Button {
                        exportInProgress = true
                        let parentIds = sections.filter { $0.exportSelected && $0.itemsCount > 0 }.map { $0.id.uuidString }
                        viewModel.shareDataLocally(for: parentIds) { error in
                            if let error = error {
                                alert = NotifyBanner(type: .error, title: "error".localized(), message: "errorOccurred".localized(with: error.localizedDescription))
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .onChange(of: viewModel.showErrorBanner) {
            showErrorMessage()
        }
        .bannerView(toast: $alert)
        .navigationBarTitle("dataFetch".localized(), displayMode: .large)
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let datesString = maxDateRange {
                Text(datesString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if let elapsedTime = elapsedTime {
                Text(elapsedTime)
                    .font(.callout)
                    .foregroundColor(.gray)
            }

            if exportInProgress {
                Text("exported".localized(with: viewModel.progressCounter))
                    .font(.callout)
                    .foregroundColor(.gray)
            }
        }
        .padding(.bottom, 14)
    }

    private var footer: some View {
        Text(readyToExport ? "healthKitDataImported".localized() : "firstTimePermissionMessage".localized())
        .padding(.horizontal, 20)
        .font(.footnote)
        .foregroundColor(.gray)
    }

    private var actionLoadDataButton: some View {
        Button {
            loadAppleHealth()
        } label: {
            HStack {
                Text(viewModel.isLoadingData ? "fetching".localized() : sections.isEmpty ? "startFetching".localized() : "updateData".localized())
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(viewModel.isLoadingData ? .gray : Color.accentColor)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .disabled(viewModel.isLoadingData)
    }

    private var actionUploadButton: some View {
        Button {
            importFinished = false
            let parentIds = sections.filter { $0.exportSelected && $0.itemsCount > 0 }.map { $0.id.uuidString }
            viewModel.selectedParentIds = parentIds
            navigationPath.append(HealthDataNavigationDestination.uploadFiles)
        } label: {
            HStack {
                Text("pushToDigiMeLibrary".localized())
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(viewModel.isLoadingData ? .gray : Color.accentColor)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .disabled(viewModel.isLoadingData)
    }

    private var content: some View {
        LazyVStack {
            ForEach(Array(sections.enumerated()), id: \.element.id) { _, section in
                Section {
                    Button {
//                        flags[sectionIndex].toggle()
                    } label: {
                        HStack {
                            Image(systemName: HealthDataType(type: HealthDataType.getTypeById(section.typeIdentifier)!).systemIcon)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .leading)
                                .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
                                .disabled(viewModel.isLoadingData)

                            HStack {
                                VStack(alignment: .leading) {
                                    Text(HealthDataType(type: HealthDataType.getTypeById(section.typeIdentifier)!).name)
                                        .foregroundColor(viewModel.isLoadingData ? .gray : .primary)
                                    if let datesString = getItemDateRangeString(section) {
                                        Text(datesString)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Text("\(section.itemsCount)")
                                    .foregroundColor(viewModel.isLoadingData ? .gray : .primary)

                                Toggle("", isOn:
                                        Binding(
                                            get: { section.exportSelected },
                                            set: { _, _ in
                                                section.exportSelected.toggle()
                                            })
                                )
                                    .labelsHidden()
                            }

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(viewBackground)
                    }
                    .disabled(viewModel.isLoadingData)
                }
            }
        }
    }

    private var startOverButton: some View {
        Button {
            startOver()
        } label: {
            Text("resetLocalCache".localized())
                .font(.headline)
                .foregroundColor(viewModel.isLoadingData ? .gray : .red)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .disabled(viewModel.isLoadingData)
    }

    private func makeServiceRow(for indexPath: IndexPath, sectionItem: HealthDataExportItem) -> some View {
        HStack {
            Toggle("", isOn:
                    Binding(
                        get: { sectionItem.isSelected },
                        set: { _, _ in
//                            viewModel.toggleItemSelected(at: indexPath)
                        })
            )
            .frame(width: 50)
            .opacity(viewModel.isLoadingData ? 0.8 : 1.0)

            VStack(alignment: .leading) {
                Text(sectionItem.stringValue)
                    .font(.title3)
                    .opacity(viewModel.isLoadingData ? 0.8 : 1.0)

                Text(Self.formatter.string(from: sectionItem.createdDate))
                    .font(.footnote)
                    .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Image(systemName: "chevron.right")
                .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
        }
        .frame(maxWidth: .infinity)
    }

    private var servicesButtonStyle: SourceSelectorButtonStyle {
        SourceSelectorButtonStyle(backgroundColor: Color("pickerItemColor", bundle: Localization.module), foregroundColor: viewModel.isLoadingData ? .gray : .primary, padding: 15)
    }

    private var viewBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color("pickerItemColor", bundle: Localization.module), lineWidth: 2)
    }

    private func getItemDateRangeString(_ section: HealthDataExportSection) -> String? {
        guard
            let minDate = section.minDate,
            let maxDate = section.maxDate else {
            return nil
        }

        return "\(Self.formatterShort.string(from: minDate)) - \(Self.formatterShort.string(from: maxDate))"
    }

    private func getOveralDateRangeString() -> String? {
        let maxDates = sections.compactMap { $0.maxDate }
        let minDates = sections.compactMap { $0.minDate }

        guard
            let startDate = minDates.min(),
            let endDate = maxDates.max() else {
            return nil
        }

        return "\(Self.formatterShort.string(from: startDate)) - \(Self.formatterShort.string(from: endDate))"
    }

    private func startTimer() {
        importStartTime = Date()
        timerDidUpdate()
        importRefresher = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            timerDidUpdate()
        }
    }

    private func stopTimer() {
        importRefresher?.invalidate()
        importRefresher = nil
    }

    private func timerDidUpdate() {
        maxDateRange = getOveralDateRangeString()

        guard
            let startTime = importStartTime,
            let elapsed = Self.intervalFormatter.string(from: startTime.timeIntervalSinceNow) else {

            elapsedTime = "elapsedTime".localized(with: "0")
            return
        }

        elapsedTime = "elapsedTime".localized(with: elapsed)
    }

    private func startOver() {
        viewModel.startOver {
            elapsedTime = nil
            maxDateRange = nil
            navigationPath.removeLast(navigationPath.count)
        }
    }

    private func loadAppleHealth() {
        if !sections.isEmpty {
            sections.forEach { section in
                section.id = UUID()
                section.itemsCount = 0
                section.minDate = nil
                section.maxDate = nil
                section.exportSelected = true
            }
        }

        startTimer()
        viewModel.loadAppleHealth(from: startDate, to: endDate, authorisationTypes: selectedHealthDataTypes ?? []) { error in
            DispatchQueue.main.async {
                if let error = error {
                    alert = NotifyBanner(type: .error, title: "error".localized(), message: error.localizedDescription)
                }

                importFinished = true
                stopTimer()
                print("Import complete.")
            }
        }
    }

    private func showErrorMessage() {
        if let errorMessage = viewModel.errorMessage {
            alert = NotifyBanner(type: .error, title: "error".localized(), message: errorMessage)
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    return NavigationStack {
       HealthDataExportItemsView(navigationPath: .constant(NavigationPath()), startDate: .constant(Date()), endDate: .constant(Date()), selectedHealthDataTypes: .constant([.bodyMass]) )
            .navigationBarItems(trailing: Text("cancel".localized()).foregroundColor(.accentColor))
            .environmentObject(HealthDataViewModel(modelContainer: previewer!.container))
            .modelContainer(previewer!.container)
    }
}
