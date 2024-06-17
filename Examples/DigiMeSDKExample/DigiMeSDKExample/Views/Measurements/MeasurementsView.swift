//
//  MeasurementsView.swift
//  DigiMeSDKExample
//
//  Created on 05/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeHealthKit
import SwiftData
import SwiftUI

enum MeasurementsNavigationDestination: Hashable {
    case add
    case view
    case shareRemote
    case shareLocally
    case portabilityReport
}

struct MeasurementsView: View {
    @EnvironmentObject var viewModel: MeasurementsViewModel
   
    @Query(sort: [
        SortDescriptor(\SelfMeasurement.createdDate, order: .reverse)
    ]) var measurements: [SelfMeasurement]

    @Binding var navigationPath: NavigationPath

    @State private var isPressedAdd = false
    @State private var isPressedView = false
    @State private var isPressedShareRemote = false
    @State private var isPressedShareLocally = false
    @State private var isPressedPortabilityReport = false
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

            SectionView(header: "Measurements", footer: nil) {
                makeCustomButton(imageName: "plus.app",
                                 buttonText: "Add Measurement",
                                 isPressed: $isPressedAdd,
                                 imageColor: .yellow) {
                    navigationPath.append(MeasurementsNavigationDestination.add)
                }
            }
            .disabled(viewModel.isLoadingData)

            SectionView(header: nil, footer: nil) {
                makeCustomButton(imageName: "eye.circle",
                                 buttonText: "View Measurement",
                                 isPressed: $isPressedView,
                                 imageColor: .green) {
                    navigationPath.append(MeasurementsNavigationDestination.view)
                }
            }
            .disabled(viewModel.isLoadingData)

            SectionView(header: nil, footer: nil) {
                makeCustomButton(imageName: "square.and.arrow.up",
                                 buttonText: "Share Remotelly",
                                 isPressed: $isPressedShareRemote,
                                 imageColor: .pink) {
                    navigationPath.append(MeasurementsNavigationDestination.shareRemote)
                }
            }
            .disabled(viewModel.isLoadingData)

            SectionView(header: nil, footer: nil) {
                makeCustomButton(imageName: "tray.and.arrow.down",
                                 buttonText: "Share Locally",
                                 isPressed: $isPressedShareLocally,
                                 imageColor: .purple) {
                    navigationPath.append(MeasurementsNavigationDestination.shareLocally)
                }
            }
            .disabled(viewModel.isLoadingData)

            if viewModel.isAuthorized {
                SectionView(header: nil, footer: nil) {
                    makeCustomButton(imageName: "doc.badge.arrow.up",
                                     buttonText: "Portability Report",
                                     isPressed: $isPressedPortabilityReport,
                                     imageColor: .mint) {
                        navigationPath.append(MeasurementsNavigationDestination.portabilityReport)
                    }
                }
                .disabled(viewModel.isLoadingData)
            }
        }
        .navigationBarTitle("Measurements", displayMode: .inline)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(for: MeasurementsNavigationDestination.self) { destination in
            switch destination {
            case .add:
                AddMeasurementView(navigationPath: $navigationPath)
                    .environmentObject(viewModel)
            case .view:
                ViewMeasurementsView(navigationPath: $navigationPath)
                    .environmentObject(viewModel)
            case .shareLocally:
                ReportDateManagerView(navigationPath: $navigationPath, startDate: $reportStartDate, endDate: $reportEndDate, viewType: .measurement, shareLocally: true) {
                    self.exportMeasuremensLocally()
                }
                .environmentObject(viewModel)
            case .shareRemote:
                ReportDateManagerView(navigationPath: $navigationPath, startDate: $reportStartDate, endDate: $reportEndDate, viewType: .measurement, shareLocally: false) {
                    self.exportMeasuremensRemotelly()
                }
                .environmentObject(viewModel)
            case .portabilityReport:
                ReportDateManagerView(navigationPath: $navigationPath, startDate: $reportStartDate, endDate: $reportEndDate) {
                     self.loadPortabilityReport()
                }
                .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $viewModel.shareLocally) {
            ShareSheetView(shareItems: viewModel.shareUrls ?? [])
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.sharePortability) {
            ShareSheetView(shareItems: [viewModel.xmlReportURL as Any])
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
        .bannerView(toast: $alert)
    }

    private var doneButton: some View {
        Button {
            navigationPath.removeLast(navigationPath.count)
        } label: {
            Text("Done")
        }
    }

    private var shareButton: some View {
        Button {
            viewModel.shareIndividualItem()
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }

    // MARK: - Self Measurements
    
    private func exportMeasuremensLocally() {
        viewModel.save(from: reportStartDate, to: reportEndDate, locally: true) { error in
            if let error = error {
                alert = NotifyBanner(type: .error, title: "Error", message: "An error occured: \(error.localizedDescription)")
            }
        }
    }

    private func exportMeasuremensRemotelly() {
        viewModel.save(from: reportStartDate, to: reportEndDate, locally: false) { error in
            if let error = error {
                alert = NotifyBanner(type: .error, title: "Error", message: "An error occured: \(error.localizedDescription)")
            }
            else {
                self.viewModel.shareMeasurements(from: reportStartDate, to: reportEndDate) { error in
                    if let error = error {
                        alert = NotifyBanner(type: .error, title: "Error", message: "An error occured: \(error.localizedDescription)")
                    }
                    else {
                        alert = NotifyBanner(type: .success, title: "Success", message: "Self-measurements have been successfully uploaded to the data provider.")
                    }
                }
            }
        }
    }

    // MARK: - Portability Report

    private func loadPortabilityReport() {
        viewModel.loadPortabilityReport(from: reportStartDate, to: reportEndDate) { error in
            if let error = error {
                alert = NotifyBanner(type: .error, title: "Error", message: error.localizedDescription)
            }
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    let mockNavigationPath = NavigationPath()

    return NavigationStack {
        MeasurementsView(navigationPath: .constant(mockNavigationPath))
            .environmentObject(MeasurementsViewModel(modelContainer: previewer!.container))
            .modelContainer(previewer!.container)
            .environment(\.colorScheme, .dark)
    }
}
