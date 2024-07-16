//
//  HealthDataUploadFilesView.swift
//  DigiMeSDKExample
//
//  Created on 21/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeHealthKit
import SwiftData
import SwiftUI

struct HealthDataUploadFilesView: View {
    @Binding var navigationPath: NavigationPath
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @State private var alert: NotifyBanner?

    @Query(sort: [
        SortDescriptor(\HealthDataExportFile.typeIdentifier, order: .reverse)
    ]) private var files: [HealthDataExportFile]

    private var formatterShort: DateFormatter {
        let fm = DateFormatter()
        fm.dateStyle = .short
        fm.timeStyle = .none
        return fm
    }

    private var uploadRequired: Bool {
        return files.isEmpty || files.contains { $0.uploadState != 3 } || viewModel.isLoadingData || !viewModel.dataFetchComplete
    }

    private let messageBeforeUpload = "uploadingProgressScreen".localized()
    private let messageAfterUpload = "resetLocalCacheDescription".localized()

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    content

                    if uploadRequired {
                        actionUploadButton
                    }

                    if !viewModel.isLoadingData {
                        startOverButton
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
            }
        }
        .onAppear {
            if uploadRequired {
                viewModel.start()
            }
        }
        .bannerView(toast: $alert)
        .navigationBarTitle("upload".localized(), displayMode: .large)
        .onChange(of: viewModel.dataFetchComplete) { _, newValue in
            if newValue {
                alert = NotifyBanner(type: .success, title: "success".localized(), message: "successfullyUploadedAllFiles".localized())
            }
        }
        .onChange(of: viewModel.showErrorBanner) {
            showErrorMessage()
        }
    }

    // MARK: - Views

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let datesString = getOveralDateRangeString() {
                Text(datesString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if let elapsedTime = viewModel.elapsedTime {
                Text(elapsedTime)
                    .font(.callout)
                    .foregroundColor(.gray)
            }

            if let progress = getUploadProgressString() {
                Text(progress)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
        }
        .padding(.bottom, 14)
    }

    private var footer: some View {
        Text(uploadRequired ? messageBeforeUpload : messageAfterUpload)
        .padding(.horizontal, 20)
        .font(.footnote)
        .foregroundColor(.gray)
    }

    private var actionUploadButton: some View {
        Button {
            viewModel.start()
        } label: {
            HStack {
                Text(viewModel.isLoadingData ? "processing".localized() : "process".localized())
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
            ForEach(Array(files.enumerated()), id: \.element.id) { _, file in
                Section {
                    Button {
                        viewModel.shareLocally = true
                        viewModel.shareUrls = [file.fileURL]
                    } label: {
                        HStack {
                            Image(systemName: HealthDataType(type: HealthDataType.getTypeById(file.typeIdentifier)!).systemIcon)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20, alignment: .leading)
                                .opacity(viewModel.isLoadingData ? 0.8 : 1.0)
                                .disabled(viewModel.isLoadingData)

                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(HealthDataType(type: HealthDataType.getTypeById(file.typeIdentifier)!).name)
                                        .foregroundColor(viewModel.isLoadingData ? .gray : .primary)
                                    HStack {
                                        Text("fileItemCount".localized(with: file.itemCount))
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                        Text(getItemDateRangeString(file))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            Spacer()

                            UploadStateIconView(uploadState: UploadState(rawValue: file.uploadState)!)
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
            viewModel.startOver {
                navigationPath.removeLast(navigationPath.count)
            }
        } label: {
            Text("resetLocalCache".localized())
                .font(.headline)
                .foregroundColor(viewModel.isLoadingData ? .gray : .red)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .disabled(viewModel.isLoadingData)
    }

    private var servicesButtonStyle: SourceSelectorButtonStyle {
        SourceSelectorButtonStyle(backgroundColor: Color("pickerItemColor", bundle: Localization.module), foregroundColor: viewModel.isLoadingData ? .gray : .primary, padding: 15)
    }

    private var viewBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color("pickerItemColor", bundle: Localization.module), lineWidth: 2)
    }

    // MARK: - Utility functions

    private func getItemDateRangeString(_ file: HealthDataExportFile) -> String {
        let minDate = file.dataStartDate
        let maxDate = file.dataEndDate
        return "\(formatterShort.string(from: minDate)) - \(formatterShort.string(from: maxDate))"
    }

    private func getOveralDateRangeString() -> String? {
        guard !files.isEmpty else {
            return nil
        }

        let minDate = files.min { $0.dataStartDate < $1.dataStartDate }?.dataStartDate ?? Date(timeIntervalSince1970: 0)
        let maxDate = files.max { $0.dataEndDate < $1.dataEndDate }?.dataEndDate ?? Date(timeIntervalSinceNow: 0)
        return "\(formatterShort.string(from: minDate)) - \(formatterShort.string(from: maxDate))"
    }

    private func getUploadProgressString() -> String? {
        return "uploadedFromTotal".localized(with: files.filter { $0.uploadState == 3 }.count, files.count)
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
        HealthDataUploadFilesView(navigationPath: .constant(NavigationPath()))
            .navigationBarItems(trailing: Text("cancel".localized()).foregroundColor(.accentColor))
            .environmentObject(HealthDataViewModel(modelContainer: previewer!.container))
            .modelContainer(previewer!.container)
    }
}
