//
//  HealthDataHomeView.swift
//  DigiMeSDKExample
//
//  Created on 22/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import SwiftData
import SwiftUI

enum HealthDataNavigationDestination: Hashable {
    case permissions
    case dateRange
    case resultExportItems
    case resultDetails
    case uploadFiles
}

struct HealthDataHomeView: View {
    @EnvironmentObject var viewModel: HealthDataViewModel

    @Query(sort: [
        SortDescriptor(\HealthDataExportFile.typeIdentifier, order: .reverse)
    ]) private var files: [HealthDataExportFile]

    @Binding var navigationPath: NavigationPath

    @State private var isFilePickerPresented = false
    @State private var isPressedShareAppleHealth = false
    @State private var reportStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var reportEndDate = Date()
    @State private var alert: NotifyBanner?
    @State private var selectedHealthDataTypes: [QuantityType]?

    var body: some View {
        ScrollView {
            SectionView(header: "Contract") {
                StyledPressableButtonView(text: UserPreferences.shared().activeContract?.name ?? Contracts.development.name,
                                          iconSystemName: "gear",
                                          iconForegroundColor: .gray,
                                          textForegroundColor: .gray,
                                          backgroundColor: Color(.secondarySystemGroupedBackground),
                                          disclosureIndicator: false,
                                          isDisabled: true) {
                }
            }
            .disabled(true)

            SectionView(header: "Cloud Storage") {
                EditableTextAndActionView(text: $viewModel.cloudId, disabled: $viewModel.isLoadingData, placeholderText: "Paste your Cloud Id here", actionTitle: "Create New Storage Space", action: {
                    viewModel.createStorage()
                })
            }

            SectionView(header: "File Operations") {
                EditableTextAndActionView(text: $viewModel.downloadFileNameWithPath, 
                                          disabled: $viewModel.isLoadingData,
                                          placeholderText: "'folder/file.txt' or 'file.txt' or 'folder'",
                                          actionTitle: "Download",
                                          action: {
                    viewModel.downloadFile()
                }, action2Title: "Delete", action2: {
                    viewModel.deleteFile()
                }, action3Title: "Delete Folder & Content", action3: {
                    viewModel.deleteFolder()
                }, action4Title: "File List", action4: {
                    viewModel.fileList()
                }, action5Title: "Upload") {
                    isFilePickerPresented = true
                }
            }

            SectionView(header: "Medmij Flow") {
                makeCustomButton(imageName: "heart.fill",
                                 buttonText: "Export Apple Health to Cloud Storage",
                                 isPressed: $isPressedShareAppleHealth,
                                 imageColor: .red) {
                    guard viewModel.isCloudCreated else {
                        viewModel.errorMessage = "Missing cloud id"
                        viewModel.showErrorBanner.toggle()
                        return
                    }

                    files.isEmpty ? navigationPath.append(HealthDataNavigationDestination.permissions) : navigationPath.append(HealthDataNavigationDestination.uploadFiles)
                }
            }
            .disabled(viewModel.isLoadingData)
        }
        .navigationBarTitle("Storage", displayMode: .large)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(for: HealthDataNavigationDestination.self) { destination in
            switch destination {
            case .permissions:
                HealthDataPermissionView(navigationPath: $navigationPath) { selectedDataTypes in
                    selectedHealthDataTypes = selectedDataTypes
                }

            case .dateRange:
                ReportDateManagerView(navigationPath: $navigationPath, startDate: $reportStartDate, endDate: $reportEndDate, viewType: .appleHealth) {
                    navigationPath.append(HealthDataNavigationDestination.resultExportItems)
                }
                .environmentObject(viewModel)

            case .resultExportItems:
                HealthDataExportItemsView(navigationPath: $navigationPath, startDate: $reportStartDate, endDate: $reportEndDate, selectedHealthDataTypes: $selectedHealthDataTypes)
                    .environmentObject(viewModel)

            case .resultDetails:
                JSONTreeView(viewModel.fhirJson ?? JSON())
                    .navigationTitle("FHIR Object")
                    .navigationBarItems(trailing: Button { viewModel.shareIndividualItem() } label: { Image(systemName: "square.and.arrow.up") })
            case .uploadFiles:
                HealthDataUploadFilesView(navigationPath: $navigationPath)
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $viewModel.shareLocally) {
            ShareSheetView(shareItems: viewModel.shareUrls ?? [])
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showFileList) {
            HealthDataStorageFileListView(fileList: viewModel.storageFileList)
                .presentationDetents([.medium, .large])
        }
        .toolbar {
            if viewModel.isLoadingData {
                ActivityIndicator()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
        .onChange(of: viewModel.showErrorBanner) {
            showErrorMessage()
        }
        .onChange(of: viewModel.showSuccessBanner) {
            showSuccessMessage()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                self.viewModel.uploadFile(from: urls.first)
            case .failure(let error):
                self.viewModel.errorMessage = error.localizedDescription
                self.viewModel.showErrorBanner.toggle()
            }
        }
        .bannerView(toast: $alert)
    }

    private func showSuccessMessage() {
        if let message = viewModel.successMessage {
            alert = NotifyBanner(type: .success, title: "Success", message: message, duration: 5)
        }
    }

    private func showErrorMessage() {
        if let message = viewModel.errorMessage {
            alert = NotifyBanner(type: .error, title: "Error", message: message, duration: 5)
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    let mockNavigationPath = NavigationPath()

    return NavigationStack {
        HealthDataHomeView(navigationPath: .constant(mockNavigationPath))
            .environmentObject(HealthDataViewModel(modelContainer: previewer!.container))
            .modelContainer(previewer!.container)
//            .environment(\.colorScheme, .dark)
    }
}
