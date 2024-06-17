//
//  HomeView.swift
//  DigiMeSDKExample
//
//  Created on 30/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftData
import SwiftUI

enum HomeNavigationDestination: Hashable {
    case contracts
    case servicesView
    case writeReadView
    case barChartsView
    case lineChartsView
    case summaryView
    case selfMeasurements
    case healthData
}

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    
    @State private var isPressedAddServices = false
    @State private var isPressedWriteRead = false
    @State private var isPressedAppleHealthBarCharts = false
    @State private var isPressedAppleHealthLineCharts = false
    @State private var isPressedAppleHealthSummary = false
    @State private var isPressedAppleHealthSelfMeasurements = false
    @State private var isPressedShareAppleHealth = false

    private let loggingService: LoggingServiceProtocol
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @StateObject private var servicesViewModel: ServicesViewModel
    @StateObject private var scopeViewModel: ScopeViewModel

    init(modelContainer: ModelContainer, loggingService: LoggingServiceProtocol, servicesViewModel: ServicesViewModel, scopeViewModel: ScopeViewModel) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        self.loggingService = loggingService
        self._servicesViewModel = StateObject(wrappedValue: servicesViewModel)
        self._scopeViewModel = StateObject(wrappedValue: scopeViewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                SectionView(header: "Contract") {
                    StyledPressableButtonView(text: servicesViewModel.activeContract.name,
                                              iconSystemName: "gear",
                                              iconForegroundColor: .indigo,
                                              textForegroundColor: .accentColor,
                                              backgroundColor: Color(.secondarySystemGroupedBackground),
                                              disclosureIndicator: true) {
                        navigationPath.append(HomeNavigationDestination.contracts)
                    }
                }

                SectionView(header: "Services", footer: "User can add services to digi.me and read data.") {
                    makeCustomButton(imageName: "arrow.down.circle",
                                     buttonText: "Service Data Example",
                                     isPressed: $isPressedAddServices,
                                     imageColor: .purple) {

                        navigationPath.append(HomeNavigationDestination.servicesView)
                    }
                }
                
                SectionView(header: "Push data", footer: "Users can upload data to digi.me and then read that data back.") {
                    makeCustomButton(imageName: "arrow.up.arrow.down.circle",
                                     buttonText: "Write & Read Written Data",
                                     isPressed: $isPressedWriteRead,
                                     imageColor: .green) {

                        navigationPath.append(HomeNavigationDestination.writeReadView)
                    }
                }

                SectionView(header: nil, footer: "Create, view and push self measurements") {
                    makeCustomButton(imageName: "lines.measurement.vertical",
                                     buttonText: "Self Measurements",
                                     isPressed: $isPressedAppleHealthSelfMeasurements,
                                     imageColor: .pink) {

                        navigationPath.append(HomeNavigationDestination.selfMeasurements)
                    }
                }

                SectionView(header: "Apple Health", footer: "Medmij Project") {
                    makeCustomButton(imageName: "heart.fill",
                                     buttonText: "Export Apple Health to FHIR",
                                     isPressed: $isPressedShareAppleHealth,
                                     imageColor: .red) {
                        navigationPath.append(HomeNavigationDestination.healthData)
                    }
                }

                SectionView(header: nil, footer: "Presenting Apple Health statistics collection query in a daily interval for the entire period of the digi.me contract time range. Check the Statement view for the exact daily numbers.") {
                    makeCustomButton(imageName: "chart.bar",
                                     buttonText: "Activity Bar Chart",
                                     isPressed: $isPressedAppleHealthBarCharts,
                                     imageColor: .orange) {

                        navigationPath.append(HomeNavigationDestination.barChartsView)
                    }

                    makeCustomButton(imageName: "chart.xyaxis.line",
                                     buttonText: "Activity Line Chart",
                                     isPressed: $isPressedAppleHealthLineCharts,
                                     imageColor: .red) {

                        navigationPath.append(HomeNavigationDestination.lineChartsView)
                    }
                }
                
                SectionView(header: nil, footer: "Presenting Apple Health statistics collection query result as totals within the digi.me contract time range. You can limit your query by turning on Scoping.") {
                    makeCustomButton(imageName: "sum",
                                     buttonText: "Activity Summary",
                                     isPressed: $isPressedAppleHealthSummary,
                                     imageColor: .indigo) {

                        navigationPath.append(HomeNavigationDestination.summaryView)
                    }
                }
            }
            .navigationBarTitle("digi.me SDK", displayMode: .large)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: HomeNavigationDestination.self) { destination in
                switch destination {
                case .contracts:
                    ContractDetailsView(selectedContract: $servicesViewModel.activeContract, contracts: Contracts.all)
                case .servicesView:
                    ServicesView(navigationPath: $navigationPath)
                        .environmentObject(servicesViewModel)
                        .environmentObject(scopeViewModel)
                case .writeReadView:
                    WriteDataView(navigationPath: $navigationPath)
                        .environmentObject(WriteDataViewModel(modelContext: modelContext))
                case .barChartsView:
                    AppleHealthBarChartView()
                case .lineChartsView:
                    AppleHealthLineChartView()
                case .summaryView:
                    AppleHealthSummaryView()
                case .selfMeasurements:
                    MeasurementsView(navigationPath: $navigationPath)
                        .environmentObject(MeasurementsViewModel(modelContainer: modelContainer))
                case .healthData:
                    HealthDataHomeView(navigationPath: $navigationPath)
                        .environmentObject(HealthDataViewModel(modelContainer: modelContainer))
                }
            }
        }
    }
}

#Preview {
    let previewer = try? Previewer()
    let loggingService = LoggingService(modelContainer: previewer!.container)
    let servicesViewModel = ServicesViewModel(loggingService: loggingService, modelContainer: previewer!.container)
    let scopeViewModel = ScopeViewModel()
    return HomeView(modelContainer: previewer!.container, loggingService: loggingService, servicesViewModel: servicesViewModel, scopeViewModel: scopeViewModel)
            .environment(\.colorScheme, .dark)
}
