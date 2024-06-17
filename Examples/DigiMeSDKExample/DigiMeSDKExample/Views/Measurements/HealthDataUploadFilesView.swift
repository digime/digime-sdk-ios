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

    private let messageBeforeUpload = """
            You are currently viewing the uploading progress screen. This screen displays the files you have selected in the previous steps, which are now queued for upload to your library. Your library is a provisional cloud storage space dedicated to the files you have chosen to push here.

            Current Actions:

            - Upload Progress: Each file is being uploaded to your library. Once uploaded, the file will be removed from the local buffer and securely stored in your cloud library.

            Important Information:

            - Data Handling: The data being uploaded consists of Apple Health exported items in FHIR format. Please note that the actual Apple Health data on your device will not be affected. The files being handled here are copies meant for upload to your library.
            """

    private let messageAfterUpload = "Tap 'Reset Local Cache' to clear all locally stored information and prepare for a new export session. This action will only remove temporary files from your device and will not affect your Apple Health data or files already uploaded to your cloud library. Restart the export process with a clean slate."

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
        .navigationBarTitle("Upload", displayMode: .large)
        .onChange(of: viewModel.dataFetchComplete) { _, newValue in
            if newValue {
                alert = NotifyBanner(type: .success, title: "Success", message: "Successfully uploaded all files")
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
                Text(viewModel.isLoadingData ? "Processing..." : "Process")
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
                                        Text("\(file.itemCount) items")
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
            Text("Reset Local Cache")
                .font(.headline)
                .foregroundColor(viewModel.isLoadingData ? .gray : .red)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .disabled(viewModel.isLoadingData)
    }

    private var servicesButtonStyle: SourceSelectorButtonStyle {
        SourceSelectorButtonStyle(backgroundColor: Color("pickerItemColor"), foregroundColor: viewModel.isLoadingData ? .gray : .primary, padding: 15)
    }

    private var viewBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color("pickerItemColor"), lineWidth: 2)
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
        return "Uploaded \(files.filter { $0.uploadState == 3 }.count) from \(files.count)"
    }

    private func showErrorMessage() {
        if let errorMessage = viewModel.errorMessage {
            alert = NotifyBanner(type: .error, title: "Error", message: errorMessage)
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    return NavigationStack {
        HealthDataUploadFilesView(navigationPath: .constant(NavigationPath()))
            .navigationBarItems(trailing: Text("Cancel").foregroundColor(.accentColor))
            .environmentObject(HealthDataViewModel(modelContainer: previewer!.container))
            .modelContainer(previewer!.container)
    }
}
