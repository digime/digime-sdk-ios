//
//  HealthDataPermissionView.swift
//  DigiMeSDKExample
//
//  Created on 10/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeHealthKit
import SwiftUI
import SwiftData

enum HealthDataNavigationDestination: Hashable {
    case permissions
    case dateRange
    case resultExportItems
    case uploadFiles
}

public struct HealthDataPermissionView: View {
    @StateObject private var viewModel: HealthDataViewModel
    @State private var navigationPath = NavigationPath()

    @StateObject private var height = HealthDataType(type: QuantityType.height)
    @StateObject private var bodyMass = HealthDataType(type: QuantityType.bodyMass)
    @StateObject private var bodyTemperature = HealthDataType(type: QuantityType.bodyTemperature)
    @StateObject private var bloodGlucose = HealthDataType(type: QuantityType.bloodGlucose)
    @StateObject private var oxygenSaturation = HealthDataType(type: QuantityType.oxygenSaturation)
    @StateObject private var respiratoryRate = HealthDataType(type: QuantityType.respiratoryRate)
    @StateObject private var heartRate = HealthDataType(type: QuantityType.heartRate)
    @StateObject private var bloodPressureSystolic = HealthDataType(type: QuantityType.bloodPressureSystolic)
    @StateObject private var bloodPressureDiastolic = HealthDataType(type: QuantityType.bloodPressureDiastolic)
    
    @State private var reportStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var reportEndDate = Date()
    @State private var healthDataTypes: [HealthDataType] = []
    @State private var isFilePickerPresented = false
    @State private var isPressedShareAppleHealth = false
    @State private var updateToggleState = false
    @State private var toggled = true
    @State private var selectedHealthDataTypes: [QuantityType]?
    @State private var alert: NotifyBanner?
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private var onProceed: (([QuantityType]?) -> Void)?

    init(modelContainer: ModelContainer, onProceed: (([QuantityType]?) -> Void)? = nil) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        self._viewModel = StateObject(wrappedValue: HealthDataViewModel(modelContainer: modelContainer))
        self.onProceed = onProceed
    }

    private var footer: some View {
        Text("allowImportAppleHealthData".localized())
            .padding(.horizontal, 20)
            .font(.footnote)
            .foregroundColor(.gray)
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(toggled ? "turnOffAll".localized() : "turnOnAll".localized(), isOn: $toggled)
                        .onChange(of: toggled) { _, newValue in
                            toggleHealthDataTypes(newValue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.systemGray6))
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                        .padding(.vertical, 15)

                    Text("appleHealthDataTypes".localized())
                        .foregroundColor(.gray)
                        .textCase(.uppercase)

                    ForEach($healthDataTypes.indices, id: \.self) { index in
                        HealthDataToggleView(healthDataType: $healthDataTypes[index]) {
                            updateToggleState.toggle()
                        }
                    }

                    Button {
                        guard viewModel.isCloudCreated else {
                            viewModel.errorMessage = "missingCloudId".localized()
                            viewModel.showErrorBanner.toggle()
                            return
                        }
                        
                        proceed()
                    } label: {
                        HStack {
                            Text("next".localized())
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.white)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(canProceed ? Color.accentColor : .gray)
                        )
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .disabled(!canProceed)

                    footer
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                initDefault()
                toggleHealthDataTypes(toggled)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitle("sources".localized(), displayMode: .large)
            .navigationDestination(for: HealthDataNavigationDestination.self) { destination in
                switch destination {
                case .permissions:
                    HealthDataPermissionView(modelContainer: modelContainer) { selectedDataTypes in
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
                        .modelContainer(modelContainer)

                case .uploadFiles:
                    HealthDataUploadFilesView(navigationPath: $navigationPath)
                        .environmentObject(viewModel)
                        .modelContainer(modelContainer)
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
                    ProgressView()
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
    }

    private func initDefault() {
        healthDataTypes = [
            height, bodyMass, bodyTemperature, bloodGlucose, oxygenSaturation, respiratoryRate, heartRate, bloodPressureSystolic, bloodPressureDiastolic
        ]
    }

    private func toggleHealthDataTypes(_ isToggled: Bool) {
        healthDataTypes.forEach { $0.isToggled = isToggled }
    }

    private var canProceed: Bool {
        return healthDataTypes.contains { $0.isToggled }
    }

    private func proceed() {
        let selected = healthDataTypes.filter { $0.isToggled }.compactMap { $0.type as? QuantityType }
        onProceed?(selected)
        selectedHealthDataTypes = selected
        navigationPath.append(HealthDataNavigationDestination.dateRange)
    }

    private func showSuccessMessage() {
        if let message = viewModel.successMessage {
            alert = NotifyBanner(type: .success, title: "success".localized(), message: message, duration: 5)
        }
    }

    private func showErrorMessage() {
        if let message = viewModel.errorMessage {
            alert = NotifyBanner(type: .error, title: "error".localized(), message: message, duration: 5)
        }
    }
}

fileprivate struct HealthDataToggleView: View {
    @Binding var healthDataType: HealthDataType
    var onUpdate: () -> Void

    var body: some View {
        HStack {
            Image(systemName: healthDataType.systemIcon)
                .renderingMode(.original)
                .foregroundColor(healthDataType.iconColor)
                .frame(width: 30, height: 30)
            Text(healthDataType.name)
            Spacer()
            Toggle("", isOn: $healthDataType.isToggled)
                .onChange(of: healthDataType.isToggled) { _, _ in
                    onUpdate()
                }
                .labelsHidden()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
}
