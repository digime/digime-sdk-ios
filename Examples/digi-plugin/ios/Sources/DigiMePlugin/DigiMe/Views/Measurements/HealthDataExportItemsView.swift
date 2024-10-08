//
// HealthDataExportItemsView.swift
//  DigiMeSDKExample
//
//  Created on 03/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import Combine
import DigiMeCore
import DigiMeHealthKit
import SwiftData
import SwiftUI

@available(iOS 17.0, *)
struct HealthDataExportItemsView: View {
    @ObservedObject private var viewModel: HealthDataViewModel
    @Binding private var navigationPath: NavigationPath
    @Binding private var startDate: Date
    @Binding private var endDate: Date
    @Binding private var showModal: Bool

    @State private var alert: NotifyBanner?
    @State private var updateTask: Task<Void, Never>?

    private var readyToExport: Bool {
        return !viewModel.isLoadingData && viewModel.importFinished && viewModel.sections.contains { $0.itemsCount > 0 }
    }

    private var allFinished: Bool {
        return !viewModel.isLoadingData && viewModel.importFinished && viewModel.exportFinished && viewModel.sections.contains { $0.itemsCount > 0 }
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

    init(viewModel: HealthDataViewModel, navigationPath: Binding<NavigationPath>, startDate: Binding<Date>, endDate: Binding<Date>, showModal: Binding<Bool>) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._navigationPath = navigationPath
        self._startDate = startDate
        self._endDate = endDate
        self._showModal = showModal
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                    .animation(.easeInOut, value: readyToExport)

                ForEach(viewModel.sections) { section in
                    sectionView(for: section)
                }

                actionButton
                    .animation(.easeInOut, value: actionButtonTitle)

                if readyToExport {
                    returnToEditButton
                }
                
                footerView
            }
        }
        .animation(.easeInOut, value: viewModel.isLoadingData)
        .onAppear() {
            startPeriodicUpdates()
        }
        .onDisappear {
            stopPeriodicUpdates()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if viewModel.isLoadingData {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .frame(width: 20, height: 20)
                }
                else if readyToExport {
                    Button {
                        let parentIds = viewModel.sections.filter { $0.exportSelected && $0.itemsCount > 0 }.map { $0.id.uuidString }
                        viewModel.shareData(for: parentIds, locally: true)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .onChange(of: viewModel.showErrorBanner) { _, newValue in
            guard newValue else {
                return
            }

            showErrorMessage()
            viewModel.showErrorBanner = false
        }
        .onChange(of: viewModel.showSuccessBanner) { _, newValue in
            guard newValue else {
                return
            }

            showSuccessMessage()
            viewModel.showSuccessBanner = false
        }
        .overlay(
            ModalDialogView(
                isPresented: $viewModel.showFinishConfirmationDialog,
                title: "confirmation".localized(),
                message: "finishTitleSuccessful".localized(),
                cancelButtonTitle: "cancel".localized(),
                proceedButtonTitle: "proceed".localized(),
                cancelAction: viewModel.onCancelTapped,
                proceedAction: viewModel.onProceedToFinishTapped
            )
        )
        .padding(.horizontal, 20)
        .scrollIndicators(.hidden)
        .bannerView(toast: $alert)
        .navigationBarTitle("confirmation".localized(), displayMode: .large)
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let datesString = getOverallDateRangeString() {
                Text(datesString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Group {
                if viewModel.isExporting {
                    Text("Elapsed Export Time: \(formatElapsedTime(viewModel.exportElapsedTime))")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text("Files Exported: \(viewModel.numberOfExportedFiles)")
                        .font(.callout)
                        .foregroundColor(.gray)
                } 
                else {
                    Text("Elapsed Import Time: \(formatElapsedTime(viewModel.importElapsedTime))")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text("Items Imported: \(viewModel.totalItemsCount)")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            .id(viewModel.isExporting) // Forces view update when isExporting changes

            if readyToExport {
                Text("pushDataToVaultDescription".localized())
                    .font(.callout)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.isExporting)
    }

    private var footerView: some View {
        Text(readyToExport ? "healthKitDataImported".localized() : "firstTimePermissionMessage".localized())
            .padding(.horizontal, 20)
            .font(.footnote)
            .foregroundColor(.gray)
    }

    private var actionButton: some View {
        Button {
            if readyToExport {
                viewModel.saveOutputToFiles()
            }
        } label: {
            HStack {
                Text(actionButtonTitle)
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
    }

    private var actionButtonTitle: String {
        guard !viewModel.isLoadingData else {
            if viewModel.importFinished {
                return "exporting".localized()
            }
            else {
                return "fetching".localized()
            }
        }

        if viewModel.sections.isEmpty {
            return "startFetching".localized()
        }
        else {
            if readyToExport && !allFinished {
                return "saveToVault".localized()
            }
            else if allFinished {
                return "done".localized()
            }
            else {
                return "updateData".localized()
            }
        }
    }

    private var contentView: some View {
        LazyVStack {
            ForEach(viewModel.sections) { section in
                sectionView(for: section)
            }
        }
    }

    private func sectionView(for section: HealthDataExportSection) -> some View {
        HStack {
            Image(systemName: HealthDataType(type: HealthDataType.getTypeById(section.typeIdentifier)!).systemIcon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20, alignment: .leading)
                .opacity(viewModel.isLoadingData ? 0.8 : 1.0)

            VStack(alignment: .leading) {
                Text(HealthDataType(type: HealthDataType.getTypeById(section.typeIdentifier)!).name)
                    .foregroundColor(viewModel.isLoadingData ? .gray : .primary)
                if let minDate = section.minDate, let maxDate = section.maxDate {
                    Text("\(Self.formatterShort.string(from: minDate)) - \(Self.formatterShort.string(from: maxDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text("\(section.itemsCount)")
                .foregroundColor(viewModel.isLoadingData ? .gray : .primary)

            Toggle("", isOn: Binding(
                get: { section.exportSelected },
                set: { _ in viewModel.toggleSectionExport(section) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(viewBackground)
    }

    private var returnToEditButton: some View {
        Button {
            startOver()
        } label: {
            Text("editImportOptions".localized())
                .font(.headline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
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
        guard let minDate = section.minDate,
              let maxDate = section.maxDate else {
            return nil
        }

        return "\(Self.formatterShort.string(from: minDate)) - \(Self.formatterShort.string(from: maxDate))"
    }

    private func getOverallDateRangeString() -> String? {
        let maxDates = viewModel.sections.compactMap { $0.maxDate }
        let minDates = viewModel.sections.compactMap { $0.minDate }

        guard let startDate = minDates.min(),
              let endDate = maxDates.max() else {
            return nil
        }

        return "\(Self.formatterShort.string(from: startDate)) - \(Self.formatterShort.string(from: endDate))"
    }

    private func startPeriodicUpdates() {
        updateTask = Task {
            while !Task.isCancelled {
                await viewModel.updateSectionsAndItemCount()
                await MainActor.run {
                    viewModel.updateElapsedTime()
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
    }

    private func stopPeriodicUpdates() {
        updateTask?.cancel()
        updateTask = nil
    }

    private func startOver() {
        Task {
            await viewModel.resetAllData()
            await MainActor.run {
                navigationPath.removeLast(navigationPath.count)
                showModal = false
            }
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

    private func showSuccessMessage() {
        if let message = viewModel.successMessage {
            alert = NotifyBanner(type: .success, title: "success".localized(), message: message, duration: 5)
        }
    }

    private func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
        Self.intervalFormatter.string(from: timeInterval) ?? "0s"
    }
}

@available(iOS 17.0, *)
#Preview {
    return NavigationStack {
        let previewer = try? Previewer()
        let model = HealthDataViewModel(modelContainer: previewer!.container, cloudId: "cloudId", onComplete: nil)
        HealthDataExportItemsView(viewModel: model, navigationPath: .constant(NavigationPath()), startDate: .constant(Date()), endDate: .constant(Date()), showModal: .constant(true))
            .navigationBarItems(trailing: Text("cancel".localized()).foregroundColor(.accentColor))
            .modelContainer(previewer!.container)
    }
}
#endif
